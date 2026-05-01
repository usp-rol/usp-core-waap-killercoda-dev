<!--
SPDX-FileCopyrightText: 2026 United Security Providers AG, Switzerland

SPDX-License-Identifier: GPL-3.0-only
-->

&#127919; In this step you will:

* Verify Kyverno setup
* Inspect the initial Kyverno policy

> &#8987; Wait until the console on the right side shows `*** Scenario ready ***` before accessing the backend (otherwise you'll see an `HTTP 502 Bad Gateway` error)!

### Verify Kyverno setup

The [Kyverno](https://kyverno.io/) application is used as a policy enforcement engine and has been pre-installed into Kubernetes namespcae `kyverno`. Now let's verify kyverno is ready to use!

We want to list

```shell
kubectl get pods -n kyverno
```{{exec}}

> &#10071; Verify that all PODs are running otherwise policy enforcement will not be possible!

<details>
<summary>example command output</summary>

```shell
NAME                                            READY   STATUS    RESTARTS   AGE
kyverno-admission-controller-c67dcfdc7-24gps    1/1     Running   0          5m54s
kyverno-background-controller-5bdcfccf7-5ngbb   1/1     Running   0          5m54s
kyverno-cleanup-controller-c9c5b58bd-xbbj7      1/1     Running   0          5m54s
kyverno-reports-controller-8d888f4bf-cvwwr      1/1     Running   0          5m54s
```

</details>

### Inspect the initial Kyverno policy

An initial kyverno policy has been installed to the cluster requiring every Core WAAP instance to use `spec.coraza.crs.paranoiaLevel` value of `2` or higher. Let's have a look at this policy by first listing all installed policies in the cluster:

```shell
kubectl get clusterpolicy  -A
```{{exec}}

<details>
<summary>example command output</summary>

```shell
NAME                          ADMISSION   BACKGROUND   READY   AGE    MESSAGE
check-coraza-paranoia-level   true        true         True    6m1s   Ready
```

</details>

Next we want to inspect the policy and see the full content which we achieve by querying the policy resource and show it as YAML encoded version:

```shell
kubectl get clusterpolicy/check-coraza-paranoia-level -o yaml
```{{exec}}

<details>
<summary>example command output</summary>

```shell
kubectl get clusterpolicy/check-coraza-paranoia-level -o yaml
```

</details>

> &#128270; More information on how Kyverno policies are structured can be found at the [policy documentation](https://kyverno.io/docs/policy-types/overview/) on the [kyverno.io](https://kyverno.io) website.

The important sections of the policy are `validate` which defines what attribute of a `CoreWaapService` resource are to be processed and `match` which is configured to apply this policy for Kubernetes resources of kind `CoreWaapService`.

In the next step we will create Core WAAP configurations and see policy enforcement in action.
