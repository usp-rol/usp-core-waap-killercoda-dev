### Configure your CoreWaapService instance

>if you are inexperienced with kubernetes scroll down to the solution section where you'll find a step-by-step guide

Having the Core WAAP operator installed and ready to go, you can configure the USP Core WAAP instance.

We will setup an instace of Core WAAP using:

```yaml
...
```{{copy}}

(for this demo scenario the OWASP Core Rule Set and header filtering have been disabled to focus on error pages and static file configuration)

<details>
<summary>example command output

```shell
corewaapservice.waap.core.u-s-p.ch/website-usp-core-waap created
```

</details>

<details>
<summary>hint</summary>

There is a file in your home directory with an example `corewaapservice` definition ready to be applied using `kubectl apply -f` ...

</details>
<br />

Now re-check if a Core WAAP instance is active in the `backend` namespace:

```shell
kubectl get corewaapservices --all-namespaces
```{{exec}}

<details>
<summary>example command output

```shell
NAMESPACE   NAME                     AGE
backend     website-usp-core-waap    59s
```

</details>
<br />

Check if a Core WAAP Pod is running:

```shell
kubectl get pods \
  -l app.kubernetes.io/name=usp-core-waap \
  --all-namespaces
```{{exec}}


<details>
<summary>example command output

```shell
NAMESPACE   NAME                                      READY   STATUS    RESTARTS   AGE
backend     website-usp-core-waap-78dbbc6d8c-6w7lr    2/2     Running   0          67s
```

</details>
<br />

>wait until the Core WAAP pod is running before trying to access the API in the next step (otherwise you'll get a HTTP 502 response)!

Continue accessing the petstore API now (or consider the hidden solution in case you were not successful).

<details>
<summary>solution</summary>

First create the Core WAAP instance using

```shell
kubectl apply -f petstore-core-waap.yaml
```{{exec}}

and wait for its readiness...

```shell
kubectl wait pods \
  -l app.kubernetes.io/name=usp-core-waap \
  -n petstore \
  --for='condition=Ready'
```{{exec}}

</details>
<br />

### Access sample website via USP Core WAAP

The port forwarding was changed accordingly that the traffic to the [sample website]({{TRAFFIC_HOST1_80}}) is now routed **via USP Core WAAP**.

...

### Inspect the actions taken by USP Core WAAP

How to get more insight in why a request was blocked by the Core WAAP OpenAPI validation feature? Let's have a look at the logs!

That's it! As you see, providing custom error pages including static files is a nice feature to hide specific backend http errors or streamline the error page layout!
