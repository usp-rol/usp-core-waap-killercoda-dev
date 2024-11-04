### Configure your CoreWaapService instance

>if you are inexperienced with kubernetes scroll down to the solution section where you'll find a step-by-step guide

Having the Core WAAP operator installed and ready to go, you can configure the USP Core WAAP instance to protect the petstore API:

```shell
kubectl apply -f openapi-petstore-configmap.yaml
```{exec}

this step will setup the required openapi schema configuration (containing the openapi spec) use by Core WAAP instance, next setup an instace using

```yaml
apiVersion: waap.core.u-s-p.ch/v1alpha1
kind: CoreWaapService
metadata:
  name: petshop-usp-core-waap
  namespace: swaggerapi
spec:
  trafficProcessing:
    openapi:
      - name: openapi-petstore-v3
        config:
          schemaSource:
            configMap: openapi-petstore-v3
            key: openapi-petstore-v3.json
          scope:
            requestBody: true
            responseBody: false
  routes:
    - match:
        path: /api
        pathType: PREFIX
      trafficProcessingRefs:
        - openapi-petstore-v3
      backend:
        address: petshop
        port: 8080
        protocol:
          selection: h1
```{{copy}}

Now re-check if a Core WAAP instance is active in the swaggerapi namespace:

```shell
kubectl get corewaapservices --all-namespaces
```{{exec}}

Check if also a Core WAAP Pod is running:

```shell
kubectl get pods \
  -l app.kubernetes.io/name=usp-core-waap \
  --all-namespaces
```{{exec}}

>wait until the Core WAAP pod is running before trying to access the API in the next step (otherwise you'll get a HTTP 502 response)!

<details>
<summary>hint</summary>

There is a file in your home directory with an example `corewaapservice` definition ready to be applied using `kubectl apply -f` ...

</details>

### Access petshop API via USP Core WAAP

We changed the port forwarding accordingly that the traffic to the [petshop API]({{TRAFFIC_HOST1_8080}}) is now routed **via USP Core WAAP**. 

**TODO**: document the petshop API access differing to the first step...

```shell
curl ...
```{exec}

### Inspect the actions taken by USP Core WAAP

**TODO**: document what to filter for in order to see the block by Core WAAP...

```shell
kubectl logs -f \
  -l app.kubernetes.io/name=usp-core-waap \
  -n swaggerapi
```{{exec}}

<details>
<summary>solution</summary>

First create the Core WAAP instance using

```shell
kubectl apply -f petshop-core-waap.yaml
```{{exec}}

and wait for its readiness...

```shell
kubectl wait pods \
  -l app.kubernetes.io/name=usp-core-waap \
  -n swaggerapi \
  --for='condition=Ready'
```{{exec}}

inspect Core WAAP instance logs using

```shell
kubectl logs -f \
  -l app.kubernetes.io/name=usp-core-waap \
  -n swaggerapi
```{{exec}}

then at last access the API using

```shell
curl ...
```{exec}
</details>
