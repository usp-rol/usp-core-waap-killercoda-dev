<!--
SPDX-FileCopyrightText: 2025 United Security Providers AG, Switzerland

SPDX-License-Identifier: GPL-3.0-only
-->

# USP Core WAAP killercoda scenarios

Hands-on scenarios showing the features of [USP Core WAAP](https://www.united-security-providers.ch/), a Web Application and API Protection running in Kubernetes. Each scenario guides you step by step through a real setup (Kubernetes cluster, backend application, USP Core WAAP) right from your terminal.

## Two ways to run a scenario

| | Online on killercoda | Locally (kind) |
|---|---|---|
| **What you need** | a web browser (killercoda account) | Linux or Windows (WSL2) with `docker` or `podman`, `jq`, `python3`, `make` |
| **Environment** | Kubernetes cluster provided by [killercoda](https://killercoda.com/united-security-providers) | [kind](https://kind.sigs.k8s.io/) cluster on your machine, a runner container mimics the killercoda host |
| **Start** | open the scenario URL (see [list below](#scenarios)) | `make up SCENARIO=<scenario>` and `make shell SCENARIO=<scenario>` |
| **Instructions** | rendered next to the terminal | scenario markdown (on github or `kc-text` in the terminal) |
| **Check a step** | `CHECK` button | `kc-next` |
| **Web UIs (traffic)** | killercoda traffic links | `http://localhost:<node-port>` |
| **Time limit** | limited session duration | none (`make down SCENARIO=<scenario>` to clean up) |

Using killercoda is the easiest way to get started, running locally is useful when you want to take your time, work offline from the killercoda platform or experiment beyond the scenario.

## Scenarios

| Scenario | Topic | killercoda | Local run |
|---|---|---|---|
| [usp-core-waap-intro](usp-core-waap-intro/) | entry-level: Core Rule Set protection (preventing OWASP Juice Shop SQL-injection) | [start](https://killercoda.com/united-security-providers/scenario/usp-core-waap-intro) | `make up SCENARIO=usp-core-waap-intro` |
| [usp-core-waap-fp-intro](usp-core-waap-fp-intro/) | Core Rule Set false-positives manual handling | [start](https://killercoda.com/united-security-providers/scenario/usp-core-waap-fp-intro) | `make up SCENARIO=usp-core-waap-fp-intro` |
| [usp-core-waap-fp-autolearn](usp-core-waap-fp-autolearn/) | Core Rule Set false-positives auto-learning | [start](https://killercoda.com/united-security-providers/scenario/usp-core-waap-fp-autolearn) | `make up SCENARIO=usp-core-waap-fp-autolearn` |
| [usp-core-waap-error-mapping](usp-core-waap-error-mapping/) | error pages (information leakage prevention) | [start](https://killercoda.com/united-security-providers/scenario/usp-core-waap-error-mapping) | `make up SCENARIO=usp-core-waap-error-mapping` |
| [usp-core-waap-openapi-intro](usp-core-waap-openapi-intro/) | OpenAPI spec validation | [start](https://killercoda.com/united-security-providers/scenario/usp-core-waap-openapi-intro) | `make up SCENARIO=usp-core-waap-openapi-intro` |
| [usp-core-waap-virtual-patch](usp-core-waap-virtual-patch/) | virtual patching | [start](https://killercoda.com/united-security-providers/scenario/usp-core-waap-virtual-patch) | `make up SCENARIO=usp-core-waap-virtual-patch` |
| [usp-core-waap-csrf-protection](usp-core-waap-csrf-protection/) | CSRF policy | [start](https://killercoda.com/united-security-providers/scenario/usp-core-waap-csrf-protection) | `make up SCENARIO=usp-core-waap-csrf-protection` |
| [usp-core-waap-header-filtering](usp-core-waap-header-filtering/) | header filtering | [start](https://killercoda.com/united-security-providers/scenario/usp-core-waap-header-filtering) | `make up SCENARIO=usp-core-waap-header-filtering` |
| [usp-core-waap-graphql](usp-core-waap-graphql/) | GraphQL filtering | [start](https://killercoda.com/united-security-providers/scenario/usp-core-waap-graphql) | `make up SCENARIO=usp-core-waap-graphql` |
| [usp-core-waap-argocd](usp-core-waap-argocd/) | DevOps integration (Argo CD), 2 nodes | [start](https://killercoda.com/united-security-providers/scenario/usp-core-waap-argocd) | `make up SCENARIO=usp-core-waap-argocd` |
| [usp-core-waap-kyverno](usp-core-waap-kyverno/) | global policies using Kyverno, 2 nodes | [start](https://killercoda.com/united-security-providers/scenario/usp-core-waap-kyverno) | `make up SCENARIO=usp-core-waap-kyverno` |

All scenarios are also listed on the [United Security Providers killercoda profile](https://killercoda.com/united-security-providers). If you are new to USP Core WAAP start with `usp-core-waap-intro`.

## Run a scenario on killercoda

1. open the scenario link from the [table above](#scenarios) (login with a killercoda account if requested)
1. wait for the environment to be set up (shown in the terminal)
1. follow the instructions, click on code blocks to execute them in the terminal and press `CHECK` to continue with the next step

## Run a scenario locally

Every scenario can be run in a local kind cluster: a "runner" container acts as the killercoda host and executes the same setup and verification scripts as killercoda does.

### Prerequisites

* Linux or Windows with [WSL2](https://learn.microsoft.com/windows/wsl/) (run all commands within the WSL2 distribution), macOS is untested
* `docker` (on Windows i.e. Docker Desktop with WSL2 backend) or `podman` (rootless works)
* `jq`, `python3`, `make` and `git`
* [kind](https://kind.sigs.k8s.io/) (or run `local/kc tools` to download a pinned version to `local/.bin/`)

### Usage

```shell
git clone https://github.com/united-security-providers/usp-core-waap-killercoda.git
cd usp-core-waap-killercoda

make up SCENARIO=usp-core-waap-intro     # create cluster, start the scenario
make shell SCENARIO=usp-core-waap-intro  # open the killercoda-like terminal
make down SCENARIO=usp-core-waap-intro   # remove cluster and runner when done
```

Within the terminal follow the scenario steps (rendered on github or shown in the terminal via `kc-text`) and use

* `kc-next` : verify the current step (like `CHECK`) and continue with the next one
* `kc-verify [n]`, `kc-step n`, `kc-text [n]`, `kc-help`

Node-ports (30022 30070 30080 30081 30090) are accessible from your browser via `http://localhost:<port>` (instead of the killercoda traffic links). Setup logs are in `/var/log/killercoda/` within the terminal (or `local/kc logs <scenario>`).

### Troubleshooting

* **rootless podman** requires cgroup delegation, `local/kc` therefore runs kind within `systemd-run --user --scope -p Delegate=yes` (see [kind rootless](https://kind.sigs.k8s.io/docs/user/rootless/))
* **inotify limits**: kube-proxy failing with "too many open files" (several clusters at once) or pods of 2-node scenarios crashing with inotify errors (i.e. envoy `inotify_fd_ >= 0`): raise the limits (`sudo sysctl fs.inotify.max_user_instances=512 fs.inotify.max_user_watches=524288`, persist in `/etc/sysctl.d/`), with the default limits run one single-node scenario at a time (`local/kc up` refuses a second cluster)
* **"rootless netns: kill network process: permission denied"** on `down` (ubuntu): apparmor denies podman stopping its network helper; harmless (ignored by `local/kc`), to get rid of it add `signal (receive) peer=podman,` to `/etc/apparmor.d/local/usr.bin.pasta` and reload it (`sudo apparmor_parser -r /etc/apparmor.d/usr.bin.pasta`)

## Contributing

Want to write or modify a scenario? See [DEVELOPMENT.md](DEVELOPMENT.md).

## License

This project is licensed under [GPL-3.0-only](LICENSES/GPL-3.0-only.txt) and is [reuse](https://reuse.software/) compliant.
