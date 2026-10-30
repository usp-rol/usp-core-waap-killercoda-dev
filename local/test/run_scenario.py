#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2026 United Security Providers AG, Switzerland
#
# SPDX-License-Identifier: GPL-3.0-only

"""Replay the user journey of a killercoda scenario inside a running runner container.

For the intro and every step: enter the step (background + foreground script), execute the
{{exec}} blocks of its markdown in document order (solution sections included) within one
persistent shell, then poll the step's verify script like a user pressing CHECK.

Markdown annotations (HTML comments, not rendered by killercoda), applying to the next code block:
  <!-- test:skip -->            do not execute the block
  <!-- test:allow-fail -->      a non-zero exit code is fine
  <!-- test:expect-fail -->     the block must fail (i.e. a request denied by a policy), not retried
  <!-- test:retries N -->       retry a failing block N times (default 20)
  <!-- test:timeout N -->       per-attempt timeout in seconds (exec interrupt blocks: run duration)
and hidden blocks executed in place (i.e. to simulate browser interactions):
  <!-- test:exec
  curl -s http://127.0.0.1:30080/...
  -->
"""

import argparse
import json
import os
import queue
import re
import subprocess
import sys
import threading
import time
import uuid
from dataclasses import dataclass, field

FENCE_RE = re.compile(r"^\s*```")
FENCE_END_RE = re.compile(r"^\s*```(\{\{(?P<kind>[^}]*)\}\})?\s*$")
ANNOTATION_RE = re.compile(r"^\s*<!--\s*test:(?P<key>[a-z-]+)(\s+(?P<value>\S+))?\s*-->\s*$")
HIDDEN_START_RE = re.compile(r"^\s*<!--\s*test:exec\s*$")
# commands a user stops with ctrl-c (i.e. log follow), run for a limited time only
LONG_RUNNING_RE = re.compile(
    r"kubectl\s+logs\b[^|\n]*\s(-f|--follow)\b|kubectl\s+get\b[^|\n]*\s(-w|--watch)\b|\btail\s+(-\w*f|--follow)\b|^\s*watch\s",
    re.MULTILINE,
)

DEFAULT_RETRIES = 20
RETRY_DELAY = int(os.environ.get("KC_RETRY_DELAY", 6))
DEFAULT_BLOCK_TIMEOUT = 300
INTERRUPT_DURATION = 15


@dataclass
class Block:
    code: str
    kind: str  # exec | interrupt | hidden
    line: int
    opts: dict = field(default_factory=dict)


def is_long_running(code):
    return bool(LONG_RUNNING_RE.search(code.replace("\\\n", " ")))


def parse_blocks(text):
    """Return the executable blocks of a killercoda markdown text in document order."""
    blocks = []
    pending = {}
    lines = text.splitlines()
    i = 0
    while i < len(lines):
        line = lines[i]
        m = ANNOTATION_RE.match(line)
        if m:
            pending[m.group("key")] = m.group("value") or True
            i += 1
            continue
        if HIDDEN_START_RE.match(line):
            start = i + 1
            body = []
            i += 1
            while i < len(lines) and lines[i].strip() != "-->":
                body.append(lines[i])
                i += 1
            blocks.append(Block("\n".join(body), "hidden", start, pending))
            pending = {}
            i += 1
            continue
        if FENCE_RE.match(line):
            start = i + 1
            indent = len(line) - len(line.lstrip())
            body = []
            i += 1
            while i < len(lines) and not FENCE_END_RE.match(lines[i]):
                body.append(lines[i][indent:] if lines[i][:indent].strip() == "" else lines[i])
                i += 1
            kind = (FENCE_END_RE.match(lines[i]).group("kind") or "") if i < len(lines) else ""
            if kind == "exec":
                blocks.append(Block("\n".join(body), "exec", start, pending))
            elif kind == "exec interrupt":
                blocks.append(Block("\n".join(body), "interrupt", start, pending))
            pending = {}
            i += 1
            continue
        i += 1
    return blocks


class Shell:
    """A persistent bash inside the runner, fed through stdin (like a user typing in the terminal)."""

    def __init__(self, engine, runner, log):
        self.engine, self.runner, self.log = engine, runner, log
        self.proc = subprocess.Popen(
            [engine, "exec", "-i", runner, "bash", "--noprofile", "--norc"],
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
            text=True, bufsize=1,
        )
        self.lines = queue.Queue()
        threading.Thread(target=self._reader, daemon=True).start()
        rc, _ = self.run("export KC_QUIET=1 TERM=dumb; source /opt/kc/kcrc; cd ~", 60, echo=False)
        if rc != 0:
            raise RuntimeError("failed to initialize runner shell")

    def _reader(self):
        for line in self.proc.stdout:
            self.lines.put(line)
        self.lines.put(None)

    def _write_file(self, path, content):
        subprocess.run([self.engine, "exec", "-i", self.runner, "sh", "-c", f"cat > {path}"],
                       input=content, text=True, check=True)

    def run(self, code, timeout, interrupt_after=None, echo=True):
        """Run code in the shell; returns (rc, output). rc None means timeout (shell is unusable afterwards)."""
        token = uuid.uuid4().hex
        path = f"/tmp/kc-cmd-{token}.sh"
        self._write_file(path, code + "\n")
        # pipefail: a failing command within a pipe (i.e. "curl | jq") shows its error to the user, who would retry
        if interrupt_after:
            # long-running command (i.e. log follow) the user interrupts with ctrl-c
            cmd = f"timeout -k 5 {interrupt_after}s bash -o pipefail {path} < /dev/null; __kc_rc=$?"
        else:
            cmd = f"set -o pipefail; source {path} < /dev/null; __kc_rc=$?; set +o pipefail"
        # 141 (SIGPIPE): left side of a pipe terminated by an early exiting reader (i.e. "grep -q")
        cmd += "; [ $__kc_rc -eq 141 ] && __kc_rc=0"
        marker = f"__KC_RC_{token}__"
        # printf without leading newline: output not ending with a newline gets the marker appended
        self.proc.stdin.write(f"{cmd}; printf '%s %s\\n' {marker} $__kc_rc\n")
        self.proc.stdin.flush()
        output = []
        deadline = time.time() + timeout
        while True:
            try:
                line = self.lines.get(timeout=max(0.1, deadline - time.time()))
            except queue.Empty:
                return None, "".join(output)
            if line is None:
                return None, "".join(output) + "\n[runner shell terminated]\n"
            if marker in line:
                rest, rc = line.split(marker, 1)
                if rest:
                    output.append(rest + "\n")
                    self.log.write(rest + "\n")
                    if echo:
                        sys.stdout.write("    " + rest + "\n")
                return int(rc.split()[0]), "".join(output)
            output.append(line)
            self.log.write(line)
            if echo:
                sys.stdout.write("    " + line)
                sys.stdout.flush()

    def close(self):
        try:
            self.proc.stdin.close()
            self.proc.terminate()
        except OSError:
            pass


class ScenarioTest:
    def __init__(self, args):
        self.args = args
        self.engine, self.runner = args.engine, args.runner
        with open(os.path.join(args.scenario_dir, "index.json")) as f:
            self.index = json.load(f)
        os.makedirs(args.out, exist_ok=True)
        self.log = open(os.path.join(args.out, "transcript.log"), "w", buffering=1)
        self.results = []
        self.retried = []

    def say(self, msg):
        print(msg, flush=True)
        self.log.write(msg + "\n")

    def runner_exec(self, *cmd):
        return subprocess.run([self.engine, "exec", self.runner, *cmd], capture_output=True, text=True)

    def step_text(self, n):
        details = self.index["details"]
        entry = details["intro"] if n == 0 else details["steps"][n - 1]
        path = entry.get("text")
        if not path:
            return ""
        with open(os.path.join(self.args.scenario_dir, path)) as f:
            return f.read()

    def run_block(self, shell, n, block):
        where = f"step {n} line {block.line} ({block.kind})"
        if block.opts.get("skip"):
            self.say(f"  - skip {where}")
            return True
        retries = int(block.opts.get("retries", DEFAULT_RETRIES))
        timeout = int(block.opts.get("timeout", DEFAULT_BLOCK_TIMEOUT))
        for attempt in range(1, retries + 2):
            self.say(f"  $ [{where}, attempt {attempt}]\n" + "\n".join("    > " + l for l in block.code.splitlines()))
            if block.kind == "interrupt" or is_long_running(block.code):
                duration = int(block.opts.get("timeout", INTERRUPT_DURATION))
                rc, _ = shell.run(block.code, duration + 30, interrupt_after=duration)
                if rc == 124:
                    rc = 0
            else:
                rc, _ = shell.run(block.code, timeout)
            if rc is None:
                self.say(f"  ! timeout after {timeout}s at {where}")
                return False
            if block.opts.get("expect-fail"):
                if rc != 0:
                    return True
                self.say(f"  ! expected failure, but exit code 0 at {where}")
                return False
            if rc == 0 or block.opts.get("allow-fail"):
                if attempt > 1:
                    self.retried.append(f"{where}: passed on attempt {attempt}")
                return True
            self.say(f"  ! exit code {rc} at {where}")
            if attempt <= retries:
                time.sleep(RETRY_DELAY)
        return False

    def verify(self, n):
        details = self.index["details"]
        if n == 0 or "verify" not in details["steps"][n - 1]:
            return True
        deadline = time.time() + self.args.verify_timeout
        while True:
            r = self.runner_exec("/opt/kc/emulator.sh", "verify", str(n))
            if r.returncode == 0:
                self.say(f"  + step {n} verified")
                return True
            if time.time() > deadline:
                self.say(f"  ! step {n} verify failed after {self.args.verify_timeout}s:\n{r.stdout}{r.stderr}")
                return False
            time.sleep(5)

    def run(self):
        shell = Shell(self.engine, self.runner, self.log)
        ok = True
        try:
            for n in range(0, len(self.index["details"]["steps"]) + 1):
                title = "intro" if n == 0 else f"step {n}: {self.index['details']['steps'][n - 1]['title']}"
                self.say(f"=== {title}")
                started = time.time()
                rc, _ = shell.run(f"kc-step {n}", self.args.step_timeout)
                if rc is None:
                    self.say(f"  ! foreground of {title} did not finish within {self.args.step_timeout}s")
                    ok = False
                else:
                    ok = all(self.run_block(shell, n, b) for b in parse_blocks(self.step_text(n))) and self.verify(n)
                self.results.append((title, ok, time.time() - started))
                if not ok:
                    break
        finally:
            shell.close()
        if not ok:
            self.diagnostics()
        self.summary()
        return ok

    def diagnostics(self):
        cmds = {
            "background-logs.txt": "tail -n +1 /var/log/killercoda/*.log",
            "pods.txt": "kubectl get pods -A -o wide",
            "events.txt": "kubectl get events -A --sort-by=.lastTimestamp",
            "corewaap.txt": "kubectl get corewaapservices -A -o yaml",
            "operator-logs.txt": "kubectl logs -n usp-core-waap-operator --all-containers --tail=500 -l app.kubernetes.io/name=usp-core-waap-operator",
            "waap-logs.txt": "kubectl get pods -A -l app.kubernetes.io/name=usp-core-waap-proxy --no-headers"
                             " | while read -r ns pod _; do kubectl logs -n $ns $pod --all-containers --prefix --tail=2000; done",
            "juiceshop-logs.txt": "kubectl logs -n juiceshop juiceshop --tail=500",
        }
        for name, cmd in cmds.items():
            r = self.runner_exec("bash", "-c", cmd)
            with open(os.path.join(self.args.out, name), "w") as f:
                f.write(r.stdout + r.stderr)
        self.say(f"diagnostics written to {self.args.out}")

    def summary(self):
        self.say("=== summary " + os.path.basename(self.args.scenario_dir))
        for title, ok, duration in self.results:
            self.say(f"  {'PASS' if ok else 'FAIL'}  {duration:6.0f}s  {title}")
        for r in self.retried:
            self.say(f"  RETRIED  {r}")


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--engine", default="docker")
    p.add_argument("--runner")
    p.add_argument("--scenario-dir", required=True)
    p.add_argument("--out", default="out")
    p.add_argument("--step-timeout", type=int, default=int(os.environ.get("KC_STEP_TIMEOUT", 900)))
    p.add_argument("--verify-timeout", type=int, default=int(os.environ.get("KC_VERIFY_TIMEOUT", 300)))
    p.add_argument("--list", action="store_true", help="only list the blocks that would be executed")
    args = p.parse_args()

    if args.list:
        with open(os.path.join(args.scenario_dir, "index.json")) as f:
            index = json.load(f)
        entries = [index["details"]["intro"]] + index["details"]["steps"]
        for n, entry in enumerate(entries):
            if "text" not in entry:
                continue
            with open(os.path.join(args.scenario_dir, entry["text"])) as f:
                for b in parse_blocks(f.read()):
                    opts = " ".join(f"{k}={v}" for k, v in b.opts.items())
                    print(f"--- step {n} line {b.line} [{b.kind}] {opts}\n{b.code}")
        return 0

    if not args.runner:
        p.error("--runner is required")
    return 0 if ScenarioTest(args).run() else 1


if __name__ == "__main__":
    sys.exit(main())
