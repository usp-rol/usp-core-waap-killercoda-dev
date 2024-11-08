### Configure your CoreWaapService instance

>if you are inexperienced with kubernetes scroll down to the solution section where you'll find a step-by-step guide

Having the Core WAAP operator installed and ready to go, you can configure the USP Core WAAP instance to protect the petstore API.

First we will setup the kubernetes configmap providing the [OpenAPI specification](https://swagger.io/docs/specification/v3_0/basic-structure/) for the petstore used by the Core WAAP to validate requests:

```shell
kubectl apply -f openapi-petstore-configmap.yaml
```{{exec}}

Next we will setup an instace of Core WAAP using:

```yaml
apiVersion: waap.core.u-s-p.ch/v1alpha1
kind: CoreWaapService
metadata:
  name: petstore-usp-core-waap
  namespace: petstore
spec:
  crs:
    mode: DISABLED
  headerFiltering:
    request:
      enabled: false
    response:
      enabled: false
  trafficProcessing:
    openapi:
      - name: petstore-v3
        config:
          schemaSource:
            configMap: openapi-petstore-v3
            key: pet_store_v3.json
          scope:
            requestBody: true
            responseBody: false
  routes:
    - match:
        path: /api
        pathType: PREFIX
      trafficProcessingRefs:
        - petstore-v3
      backend:
        address: petstore
        port: 8080
        protocol:
          selection: h1
```{{copy}}

(for this demo scenario the OWASP Core Rule Set and header filtering have been disabled to focus on OpenAPI validation)

<details>
<summary>hint</summary>

There is a file in your home directory with an example `corewaapservice` definition ready to be applied using `kubectl apply -f` ...

</details>

Now re-check if a Core WAAP instance is active in the `petstore` namespace:

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

### Access petstore API via USP Core WAAP

The port forwarding was changed accordingly that the traffic to the petstore API is now routed **via USP Core WAAP** (not port 8080 anymore - just use localhost with default port 80). Next let's again query a pet in an incorrect format as we did already before:

```shell
curl -sv http://localhost/api/pet/waapcat1
```{{exec}}

This time you'll get an HTTP 400 response and will not see any request in the backend as this invalid call was intercepted by Core WAAP!

```shell
kubectl -n petstore exec pod/petstore \
  -- /bin/bash -c "tail /var/log/*-requests.log"
```{{exec}}

Now let's make sure a valid pestore API call still works:

```shell
curl -sv http://localhost/api/pet/1
```{{exec}}

**Wait! why is that also getting an HTTP 400 response?!**

Well, the configured OpenAPI specification includes an [API Keys](https://swagger.io/docs/specification/v3_0/authentication/api-keys/) section which is not enforced by the petstore application but is now since its configured to be included! In order to successfully query pet's we need to send an `api_key` header:

```shell
curl -sv --header 'api_key: anything' http://localhost/api/pet/1 | jq
```{{exec}}

Ahh...there it is again the familiar "furrr..."!

> The used OpenAPI specification is available for detailed analysis via [API definition for the Pet Store](https://github.com/swagger-api/swagger-petstore/blob/master/src/main/resources/openapi.yaml) from the swagger-api project.

### Inspect the actions taken by USP Core WAAP

How to get more insight in why a request was blocked by the Core WAAP OpenAPI validation feature? Let's have a look at the logs!

First identify the additional container name once the OpenAPI validation is configured within the `CoreWaapService` kubernetes resource:

```shell
kubectl describe pods \
  -l app.kubernetes.io/name=usp-core-waap \
  -A
```{{exec}}

Note in addition to the base `envoy` container there is a `traffic-processor-openapi-...` conatiner which will provide log insight into why an OpenAPI validation feature blocked a request. Looking into that container we see the details for OpenAPI request validations:

```shell
kubectl logs \
  -l app.kubernetes.io/name=usp-core-waap \
  -n petstore \
  -c traffic-processor-openapi-petstore-v3 \
  | jq
```{{exec}}

That's it! As you see, protecting an application through a OpenAPI specification brings a lot of additional security as demonstrated here not just with incorrect API requests but also about missing security headers (specified in API but mistakenly not enforced by the application)!

