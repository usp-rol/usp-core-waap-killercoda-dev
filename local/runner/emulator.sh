#!/bin/bash

# SPDX-FileCopyrightText: 2026 United Security Providers AG, Switzerland
#
# SPDX-License-Identifier: GPL-3.0-only

# Mimics the killercoda scenario lifecycle (driven by index.json) inside the runner container.
#
# usage: emulator.sh start | steps | title <n> | text <n> | bg <n> | fg <n> | verify <n>
#   <n> = 0 for intro, 1..N for steps, "finish" for text only

set -uo pipefail

SCENARIO_DIR="${KC_SCENARIO_DIR:-/kc/scenario}"
INDEX="${SCENARIO_DIR}/index.json"
LOG_DIR="${KC_LOG_DIR:-/var/log/killercoda}"

# step_field <n> <field> : path (relative to scenario) of intro/step/finish field, empty if not defined
step_field() {
  local n=$1 field=$2
  case "$n" in
    0) jq -r ".details.intro.${field} // empty" "$INDEX" ;;
    finish) jq -r ".details.finish.${field} // empty" "$INDEX" ;;
    *) jq -r ".details.steps[$((n - 1))].${field} // empty" "$INDEX" ;;
  esac
}

copy_assets() {
  local count i pattern target
  count=$(jq '.details.assets.host01 // [] | length' "$INDEX")
  shopt -s globstar nullglob
  for ((i = 0; i < count; i++)); do
    pattern=$(jq -r ".details.assets.host01[$i].file" "$INDEX")
    target=$(jq -r ".details.assets.host01[$i].target" "$INDEX")
    target="${target/#\~/$HOME}"
    mkdir -p "$target"
    (
      cd "${SCENARIO_DIR}/assets" || exit 1
      # shellcheck disable=SC2206
      local files=($pattern)
      for f in "${files[@]}"; do
        [ -f "$f" ] || continue
        mkdir -p "${target}/$(dirname "$f")"
        cp "$f" "${target}/${f}"
      done
    )
  done
}

# run_bg <n> : run a background script detached (as killercoda does), logging to /var/log/killercoda
run_bg() {
  local script
  script=$(step_field "$1" background)
  [ -n "$script" ] || return 0
  (cd ~ && nohup bash "${SCENARIO_DIR}/${script}" \
    > "${LOG_DIR}/background$1_stdout.log" 2> "${LOG_DIR}/background$1_stderr.log" &)
}

case "${1:-}" in
  start)
    mkdir -p "$LOG_DIR" ~/.kc
    copy_assets
    run_bg 0
    touch ~/.kc/intro-pending
    ;;
  steps)
    jq '.details.steps | length' "$INDEX"
    ;;
  title)
    case "$2" in
      0) echo "Intro: $(jq -r '.title' "$INDEX")" ;;
      finish) echo "Finish" ;;
      *) echo "Step $2: $(step_field "$2" title)" ;;
    esac
    ;;
  text)
    f=$(step_field "$2" text)
    [ -n "$f" ] && cat "${SCENARIO_DIR}/${f}"
    ;;
  bg)
    run_bg "$2"
    ;;
  fg)
    f=$(step_field "$2" foreground)
    [ -n "$f" ] && echo "${SCENARIO_DIR}/${f}"
    ;;
  verify)
    f=$(step_field "$2" verify)
    [ -n "$f" ] || exit 0
    cd ~ && bash "${SCENARIO_DIR}/${f}"
    ;;
  *)
    echo "usage: $0 start | steps | title <n> | text <n> | bg <n> | fg <n> | verify <n>" >&2
    exit 2
    ;;
esac
