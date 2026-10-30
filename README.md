<!--
SPDX-FileCopyrightText: 2025 United Security Providers AG, Switzerland

SPDX-License-Identifier: GPL-3.0-only
-->

# USP Core WAAP killercoda scenarios

This repository contains the scenarios published via [killercoda](https://killercoda.com/)

## List of scenarios

* usp-core-waap-intro            : entry-level scenario to show-case the Core WAAP using Core Rule Set protection (preventing OWASP Juice Shop SQL-injection)
* usp-core-waap-error-mapping    : scenario to show-case the Core WAAP error pages feature
* usp-core-waap-fp-intro         : scenario to show-case Core WAAP Core Rule Set false-positives manual handling
* usp-core-waap-fp-autolearn     : scenario to show-case Core WAAP Core Rule Set false-positives auto-learning
* usp-core-waap-virtual-patch    : scenario to show-case Core WAAP virtual patching feature
* usp-core-waap-openapi-intro    : scenario to show-case Core WAAP OpenAPI spec validation feature
* usp-core-waap-csrf-protection  : scenario to show-case Core WAAP CSRF policy feature
* usp-core-waap-header-filtering : scenario to show-case Core WAAP header filtering feature
* usp-core-waap-graphql          : scenario to show-case Core WAAP GraphQL filtering feature
* usp-core-waap-argocd           : scenario to show-case Core WAAP devops integration
* usp-core-waap-kyverno          : scenario to show-case Core WAAP global policies using Kyverno

All scenarios can also be tried out locally in a kind cluster, see [Run scenarios locally](#run-scenarios-locally-kind).

**Keep in mind when renaming directories the killercoda scenario URL will change!**

The order of the scenarios without a `structure.json` will be according the scenario title alphabetically sorted! Use the following command to identify wrong top-level paths inside your `structure.json` file:

```shell
for d in $(jq -r '.items[].path' structure.json);do ls -d $d;done
```

## Reuse software

This project is [reuse software](https://reuse.software/) compliant and shall remain to be!

Having the [reuse tool](https://github.com/fsfe/reuse-tool) installed, execute

```shell
reuse lint
```

in the project root directory to verify compatibility!

Once new files were added, using the `reuse` tool include the required headers by using

```shell
reuse annotate -l GPL-3.0-only -y 2025 -c "United Security Providers AG, Switzerland"  [new-files]
```

as an example and then again verify compatibility by running `reuse lint`.

## Core WAAP Artifact access

The Core WAAP project uses three types of artifacts which are

* one Helm chart
* one Operator container image
* one Base and multiple side-car container images

These artifacts are [pushed to different registries](https://wiki.swisscom.com/display/USPWAM/USP+Container+delivery#USPContainerdelivery-ContainerRegistryInfrastructure) where the Azure Dev Registry `devuspregistry.azurecr.io` is to be used for Kilercoda scenarios (otherwise RCs are not available to develop scenarios).

Since access to all these artifacts is restricted (customers use a dedicated access token) there is also one [dedicated access token](https://portal.azure.com/#@usplabsesdev.onmicrosoft.com/resource/subscriptions/2e78d607-0ada-406c-a87d-07cd55718b63/resourceGroups/dev-acr-rg/providers/Microsoft.ContainerRegistry/registries/devuspregistry/token) `killercoda` (using the `corewaap-demo` scope map) giving access to the following repositories:

* helm/usp/core/waap/usp-core-waap-operator : access to the helm chart
* usp/core/waap/demo/* : access to container images (for base Core WAAP as of 2024-Q4 demo image the others selected versions used by killercoda)

|OriginalRepo                                 | DemoRepo                                          | KillercodaAccess | Remarks                                   |
|---------------------------------------------|---------------------------------------------------|------------------|-------------------------------------------|
|helm/usp/core/waap/usp-core-waap-operator    | n/a                                               | OriginalRepo     | no demo artifact wanted                   |
|usp/core/waap/usp-core-waap-operator         | usp/core/waap/**demo**/usp-core-waap-operator         | DemoRepo         | selected images copied to demo repository (no dedicated demo image avilable yet **manually copy needed**) |
|usp/core/waap/usp-core-waap-proxy                  | usp/core/waap/**demo**/usp-core-waap-proxy-**demo** | DemoRepo         | dedicated demo image (image name "-demo") built via release process (**no need to manually copy**)|
|usp/core/waap/usp-core-waap-ext-proc-icap    | usp/core/waap/demo/usp-core-waap-ext-proc-icap    | DemoRepo         | selected images copied to demo repository  (no dedicated demo image avilable yet) |
|usp/core/waap/usp-core-waap-ext-proc-openapi | usp/core/waap/demo/usp-core-waap-ext-proc-openapi | DemoRepo         | selected images copied to demo repository  (no dedicated demo image avilable yet) |
|usp/core/waap/usp-core-waap-ext-proc-...     | usp/core/waap/demo/usp-core-waap-ext-proc-...     | DemoRepo         | selected images copied to demo repository unless dedicated demo image is available |

Note: when copying an image to another repository the storage usage does not change (Azure Container Registry recognizes the same image and links the object only)

The reason to manually copy images from `OriginalRepo` to `DemoRepo` is to control access to images (ACR does not support controlling image access only repository level). By this we also get a "view" on what images are used by public use-case like Killercoda (i.e. Killercoda uses openapi side car version 0.0.3 although 0.0.4 and 0.0.5 are released too).

In order to make a version available in the `DemoRepo` login to the `devuspregistry.azurecr.io` (using `usp-ci-bob` access token granting write access) and

1. pull original artifact
1. tag artifact into demo repository
1. push artifact to the demo repository

in the following example the `usp-core-waap-operator:1.0.1` artifact will be copied to the demo repository for being accessed by Killercoda scenarios:

```shell
docker pull devuspregistry.azurecr.io/usp/core/waap/usp-core-waap-operator:1.0.1
docker tag devuspregistry.azurecr.io/usp/core/waap/demo/usp-core-waap-operator:1.0.1
docker push devuspregistry.azurecr.io/usp/core/waap/demo/usp-core-waap-operator:1.0.1
```

For more information also read internal [Core WAAP build wiki](https://git.u-s-p.local/core-waap/core-waap-build/-/wikis/Core-WAAP-Release-Process/)

## Rules and guidelines

* use the term 'USP Core WAAP' (and not 'Core Waap' - note the uppercase waap)
* in addition also make sure to add an "overview" section at first for every step (not on intro/finish) which outlines what will be covered within this step.
* make sure to include the icon-set overview on the first `intro.text` Element (linked via `index.json`) of the scenario (see below)

**intro icon-set example**
```markdown
Throughout the scenario, the following conventions are used:

> &#10071; Important information

> &#128270; Additional details

> &#8987; Wait for a condition prior to continue
```

**step overview example**
```markdown
&#127919; In this step you will:

* Inspect the logs of USP Core WAAP
* Reconfigure the USP Core WAAP instance to ...
* Check the logs to verify false positives are gone
```

and then use headings (level 3) for each mentioned point...

## Scenario development

Read through the [killercoda creator documentation](https://killercoda.com/creators) and check the existing scenario examples at

* [https://github.com/killercoda/scenario-examples.git](https://github.com/killercoda/scenario-examples.git)
* [https://github.com/killercoda/scenario-examples-courses.git](https://github.com/killercoda/scenario-examples-courses.git)

In order to modify [USP killercoda scenarios](https://killercoda.com/united-security-providers) one has to...

1. [create a fork](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/fork-a-repo) of the "live" repo https://github.com/united-security-providers/usp-core-waap-killercoda (i.e. https://github.com/usp-rol/usp-core-waap-killercoda-dev as rol did)
1. head over to [your killercoda creator profiles](https://killercoda.com/creator/profiles) and select the profile (or create one if there is none)
1. select **repository** option (URL being `https://killercoda.com/creator/repository/$your-profile-name`) and [configure your fork repo](https://killercoda.com/creators/get-started)
1. Repo Name will be **everything after github.com/** from your fork created (i.e. usp-rol/usp-core-waap-killercoda-dev) and configure your branch (usually main)
1. Add deployment key from your [creator repository](https://killercoda.com/creator/repository) to your github fork (settings => Deploy keys)
1. Add Github webhook config from your [creator repository](https://killercoda.com/creator/repository) to your github fork (settings => Webhooks)

Test your killercoda profile https://killercoda.com/$your-profile-name and modify your fork repo by pushing to github (start with a markdown modification for example)

## Shared code and Core WAAP profiles

Killercoda only loads files from within a scenario directory, therefore code used by all scenarios lives in `shared/` and is **copied** into every scenario's `assets/` directory (files named `shared-*`, committed to git):

* `shared/common/` : version independent helpers (logging, url/marker waiting, foreground "Installing..." waiter, `shared-init.sh` loading everything)
* `shared/profiles/<profile>/` : everything that may change with a USP Core WAAP release (helm chart version and values, registry, operator install, waap helpers, auto-learning cli version)

Each scenario selects its profile and declares its specifics in `assets/scenario.env` (i.e. `SHARED_PROFILE="core-waap-2.1"`, `BACKEND_NAMESPACE`, ...). Scenario scripts start with `source ~/.scenario_staging/shared-init.sh` and then use functions like `install_backend_manifest`, `install_operator`, `copy_to_home` and `signal_marker`.

**Never edit `shared-*` files within a scenario**, edit the source in `shared/` and run

```shell
make sync        # copy shared/ into all scenarios (tools/sync-shared.sh [scenario...])
make sync-check  # verify (also run by pre-commit and CI)
```

### Updating a single scenario (i.e. to USP Core WAAP 2.2)

Scenarios can be migrated one by one as versions are pinned per scenario (via its profile):

1. `cp -r shared/profiles/core-waap-2.1 shared/profiles/core-waap-2.2` and adapt the new profile (helm version, values, ...)
1. set `SHARED_PROFILE="core-waap-2.2"` in `<scenario>/assets/scenario.env` and adapt the scenario's own resources/texts
1. `make sync && make test SCENARIO=<scenario>` (only that scenario and the new profile change)
1. once no scenario uses the old profile anymore (`make sync` reports unused profiles) remove it

For a patch release of a single scenario setting `CORE_WAAP_HELM_VERSION="2.1.3"` in its `scenario.env` is sufficient.

## Run scenarios locally (kind)

Every scenario can be run in a local [kind](https://kind.sigs.k8s.io/) cluster mimicking killercoda: a "runner" container acts as the killercoda host (`~/.scenario_staging`, `/var/log/killercoda`, `127.0.0.1:<node-port>` forwarded to the cluster) and executes the scenario's background/foreground/verify scripts as defined in its `index.json`.

Prerequisites: `docker` or `podman` (rootless works), `jq`, `python3` and `kind` (or run `local/kc tools` to download a pinned version to `local/.bin/`).

```shell
make up SCENARIO=usp-core-waap-intro     # create cluster, start the scenario (intro background script)
make shell SCENARIO=usp-core-waap-intro  # killercoda-like terminal
make down SCENARIO=usp-core-waap-intro   # remove cluster and runner
```

Within the terminal follow the scenario steps (rendered on github or shown in the terminal) and use

* `kc-next` : verify the current step (like `CHECK`) and continue with the next one
* `kc-verify [n]`, `kc-step n`, `kc-text [n]`, `kc-help`

Node-ports (30022 30070 30080 30081 30090) are also accessible from your browser via `http://localhost:<port>` (instead of the killercoda traffic links). Background script logs are in `/var/log/killercoda/` within the terminal (or `local/kc logs <scenario>`).

## Automated scenario tests

`make test SCENARIO=<scenario>` (or `make test-all`) replays the user journey in a fresh kind cluster and removes it afterwards (`KEEP=1` keeps it for inspection):

* for the intro and every step: start its background script, run its foreground script, execute all `{{exec}}` blocks of its markdown in document order (including the ones within solution sections) in one persistent shell, then poll the step's `verify.sh` like a user pressing `CHECK`
* failing blocks are retried (a user would retry too) and reported as `RETRIED` in the summary, `{{exec interrupt}}` blocks are stopped after 15s
* transcript and diagnostics (background logs, pods, events, Core WAAP logs) are written to `local/test/out/<scenario>/`

Browser interactions can't be executed, hence steps relying on them contain hidden blocks (HTML comments are not rendered by killercoda) simulating them:

```markdown
<!-- test:exec
# local test only: browser login using SQL-injection
curl -s ... http://127.0.0.1:30080/rest/user/login
-->
```

Further annotations (placed in the line before a code block): `<!-- test:skip -->`, `<!-- test:allow-fail -->`, `<!-- test:expect-fail -->`, `<!-- test:retries N -->`, `<!-- test:timeout N -->`. Avoid `--` within hidden blocks (use short options).

`make lint` runs sync-check, shellcheck and the harness unit tests. The github workflow `.github/workflows/scenarios.yaml` runs lint and tests every scenario of `structure.json` in parallel (one runner per scenario) on pull requests, manually and weekly.

### Troubleshooting

* **rootless podman** requires cgroup delegation, `local/kc` therefore runs kind within `systemd-run --user --scope -p Delegate=yes` (see [kind rootless](https://kind.sigs.k8s.io/docs/user/rootless/))
* **inotify limits**: kube-proxy failing with "too many open files" (several clusters at once) or pods of 2-node scenarios crashing with inotify errors (i.e. envoy `inotify_fd_ >= 0`): raise the limits (`sudo sysctl fs.inotify.max_user_instances=512 fs.inotify.max_user_watches=524288`, persist in `/etc/sysctl.d/`), with the default limits run one single-node scenario at a time (`local/kc up` refuses a second cluster)
* **"rootless netns: kill network process: permission denied"** on `down` (ubuntu): apparmor denies podman stopping its network helper; harmless (ignored by `local/kc`), to get rid of it add `signal (receive) peer=podman,` to `/etc/apparmor.d/local/usr.bin.pasta` and reload it (`sudo apparmor_parser -r /etc/apparmor.d/usr.bin.pasta`)

## Release development work

Once you are satisfied with your modifications (probably let them test by another team member) you then can update the "live" repo by **contributing back** via github.com to the upstream repo (consider reading through [github.com documentation](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/fork-a-repo) if unsure of how to do that).

## Debugging intro scripts

For intro scripts only there are default logs available on the console in

* `/var/log/killercoda/background0_stdout.log`
* `/var/log/killercoda/background0_stderr.log`

or accessible via https://killercoda.com/creator/debug/$your-profile-name

## Known issues

as it seems a background script outside the "intro" section will timeout after 10s and thus end in the UI showing "background script failed".
to mitigate this execute another script not waiting for finishing (and probably use [foreground/background communication](https://github.com/killercoda/scenario-examples/tree/main/foreground-background-scripts-multi-step)):

```shell
#!/bin/bash

# trigger an external script
bash ~/.scenario_staging/long-running-script.sh &
exit 0
```
