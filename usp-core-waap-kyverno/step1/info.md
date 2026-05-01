<!--
SPDX-FileCopyrightText: 2026 United Security Providers AG, Switzerland

SPDX-License-Identifier: GPL-3.0-only
-->

&#127919; In this step you will:

* Verify Kyverno setup
* Inspect the initial Kyverno policy

> &#8987; Wait until the console on the right side shows `*** Scenario ready ***`!

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
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"kyverno.io/v1","kind":"ClusterPolicy","metadata":{"annotations":{"policies.kyverno.io/description":"Ensures that CoreWaapService resources are only applied if the Coraza paranoia level is set to at least 2.","policies.kyverno.io/title":"Require Paranoia Level 2 or Higher"},"name":"check-coraza-paranoia-level"},"spec":{"background":true,"rules":[{"match":{"any":[{"resources":{"kinds":["CoreWaapService"]}}]},"name":"check-paranoia-level","validate":{"deny":{"conditions":{"all":[{"key":"{{ request.object.spec.coraza.crs.paranoiaLevel || `0` }}","operator":"LessThan","value":2}]}},"message":"The paranoia level (spec.coraza.crs.paranoiaLevel) must be 2 or higher."}}],"validationFailureAction":"Enforce"}}
    policies.kyverno.io/description: Ensures that CoreWaapService resources are only
      applied if the Coraza paranoia level is set to at least 2.
    policies.kyverno.io/title: Require Paranoia Level 2 or Higher
  creationTimestamp: "2026-05-01T14:06:57Z"
  generation: 1
  name: check-coraza-paranoia-level
  resourceVersion: "5371"
  uid: 743875c2-5128-433f-a2e0-ed53fc4fb0d4
spec:
  admission: true
  background: true
  emitWarning: false
  rules:
  - match:
      any:
      - resources:
          kinds:
          - CoreWaapService
    name: check-paranoia-level
    skipBackgroundRequests: true
    validate:
      allowExistingViolations: true
      deny:
        conditions:
          all:
          - key: '{{ request.object.spec.coraza.crs.paranoiaLevel || `0` }}'
            operator: LessThan
            value: 2
      message: The paranoia level (spec.coraza.crs.paranoiaLevel) must be 2 or higher.
  validationFailureAction: Enforce
status:
  autogen: {}
  conditions:
  - lastTransitionTime: "2026-05-01T14:06:58Z"
    message: Ready
    reason: Succeeded
    status: "True"
    type: Ready
  rulecount:
    generate: 0
    mutate: 0
    validate: 1
    verifyimages: 0
  validatingadmissionpolicy:
    generated: false
    message: ""
```

</details>

> &#128270; More information on how Kyverno policies are structured can be found at the [policy documentation](https://kyverno.io/docs/policy-types/overview/) on the [kyverno.io](https://kyverno.io) website.

The important sections of the policy are `validate` which defines what attribute of a `CoreWaapService` resource are to be processed and `match` which is configured to apply this policy for Kubernetes resources of kind `CoreWaapService`.

In the next step we will create Core WAAP configurations and see policy enforcement in action.
