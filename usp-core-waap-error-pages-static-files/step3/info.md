### Configure your CoreWaapService instance

>if you are inexperienced with kubernetes scroll down to the solution section where you'll find a step-by-step guide

Having the Core WAAP operator installed and ready to go, you can now configure the USP Core WAAP instance.

We will setup an instace of Core WAAP using:

```yaml
apiVersion: waap.core.u-s-p.ch/v1alpha1
kind: CoreWaapService
metadata:
  name: website-usp-core-waap
  namespace: backend
spec:
  webResources:
    configMap: core-waap-static-resources
    path: /resources/
    staticFiles:
    - key: style.css
    errorPages:
    - key: error4xx.html
      statusCode: 4xx
  crs:
    mode: DISABLED
  headerFiltering:
    request:
      enabled: false
    response:
      enabled: false
  routes:
    - match:
        path: /
        pathType: PREFIX
      backend:
        address: website
        port: 8080
        protocol:
          selection: h1
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
NAMESPACE   NAME                                     READY   STATUS    RESTARTS   AGE
backend     website-usp-core-waap-7849dbf5fd-4jt8c   1/1     Running   0          43s
```

</details>
<br />

>wait until the Core WAAP pod is running before trying to access the API in the next step (otherwise you'll get a HTTP 502 response)!

Continue accessing the [sample company website]({{TRAFFIC_HOST1_80}}) via Core WAAP now (or consider the hidden solution in case you were not successful).

<details>
<summary>solution</summary>

First create the Core WAAP instance using

```shell
kubectl apply -f website-core-waap.yaml
```{{exec}}

and wait for its readiness...

```shell
kubectl wait pods \
  -l app.kubernetes.io/name=usp-core-waap \
  -n backend \
  --for='condition=Ready'
```{{exec}}

</details>
<br />

### Access sample website via USP Core WAAP

The port forwarding was changed accordingly that the traffic to the [sample company website]({{TRAFFIC_HOST1_80}}) is now routed **via USP Core WAAP**.

Make sure to checkout the two products again:

* [product A]({{TRAFFIC_HOST1_80}}/product_a.html)
* [product B]({{TRAFFIC_HOST1_80}}/product_b.html)

Did you notice the different error page?
Well it was not expected but somehow the design of that error page even surpasses the design of the website...

### Inspect the actions taken by USP Core WAAP

How to get more insight in why a request was blocked by the Core WAAP OpenAPI validation feature? Let's have a look at the logs!

```shell
kubectl logs \
  -n backend \
  -l app.kubernetes.io/name=usp-core-waap \
  | grep '^{' | jq
```{{exec}}

<details>
<summary>example command output

```json
{
  "@timestamp": "2024-11-08T15:04:48.087Z",
  "request.id": "4ac60bab-b986-4513-9564-eac6aacd9314",
  "request.protocol": "HTTP/1.1",
  "request.method": "GET",
  "request.path": "/product_a.html",
  "request.total_duration": "0",
  "request.body_bytes_received": "0",
  "response.status": "404",
  "response.details": "",
  "response.flags": "-",
  "response.body_bytes_sent": "232",
  "envoy.upstream.duration": "-",
  "envoy.upstream.host": "10.109.93.26:8080",
  "envoy.upstream.route": "-",
  "envoy.upstream.cluster": "core.waap.cluster.backend-website-8080-h1",
  "envoy.upstream.bytes_sent": "1016",
  "envoy.upstream.bytes_received": "355",
  "envoy.connection.id": "22",
  "client.address": "127.0.0.1:51646",
  "client.local_address": "127.0.0.1:8080",
  "client.direct_address": "127.0.0.1:51646",
  "host.hostname": "website-usp-core-waap-7849dbf5fd-4jt8c",
  "http.req_headers.referer": "https://262e3c7e-6bbe-48d5-8aad-0d869b979dce-10-244-4-99-80.spch.r.killercoda.com/",
  "http.req_headers.useragent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36 Edg/130.0.0.0",
  "http.req_headers.authority": "website",
  "http.req_headers.forwarded_for": "-",
  "http.req_headers.forwarded_proto": "https"
}
```

</details>
<br />

That's it! As you see, providing custom error pages including static files is a nice feature to hide specific backend http errors or streamline the error page layout!
