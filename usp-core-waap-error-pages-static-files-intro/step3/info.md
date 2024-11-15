### Configure your CoreWaapService instance

>if you are inexperienced with kubernetes scroll down to the solution section where you'll find a step-by-step guide

Having the Core WAAP operator installed and ready to go, you can now configure the USP Core WAAP instance.

At first we will configure the custom error page with static content via kubernetes  `ConfigMap`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: core-waap-static-resources
  namespace: juiceshop
data:
  error5xx.html: |
    <html>
    <head>
    <title>Error Page 5xx</title>
    <link rel="stylesheet" type="text/css" href="/styles.css"/>
    </head>
    <body class="mat-app-background bluegrey-lightgreen-theme">
    <div style="position: absolute;top: 50%% ;left: 50%% ;margin-top: -50px;margin-left: -50px;width: 100px;height: 100px;">
    <div class="cdk-overlay-container bluegrey-lightgreen-theme">
    <div fxlayoutalign="center" style="place-content: stretch center; align-content: stretch; align-items: stretch; flex-direction: row; box-sizing: border-box; display: flex;">
    <mat-card class="mat-card mat-focus-indicator mat-elevation-z6" style="padding: 50px;">
      <section class="about-us">
        <h1>The application encountered an error</h1>
        <img src="/assets/public/images/JuiceShop_Logo.png" width="150" height="180" />
        <p class="text-justify">
        Please retry to access the webpage. In case the request is not successful get in touch with support@... providing the information below.
        </p>
        <p class="text-justify">
        <table border="0">
        <tr><th align="right">backend status code</th><td>: %RESPONSE_CODE%</td></tr>
        <tr><th align="right">client request id</th><td>: %REQ(X-REQUEST-ID)%</td></tr>
        <tr><th align="right">timestamp</th><td>: %START_TIME%</td></tr>
        </table>
        </p>
      </section>
    </mat-card>
    </div>
    </div>
    </div>
    </body>
    </html>
```

There is an example ConfigMap prepared for you ready to be applied using:

```shell
kubectl apply -f error-configmap.yaml
```{{exec}}

<details>
<summary>example command output

```shell
configmap/core-waap-static-resources created
```

</details>
<br />

Next, we will setup an instace of Core WAAP using the created ConfigMap using:

```yaml
apiVersion: waap.core.u-s-p.ch/v1alpha1
kind: CoreWaapService
metadata:
  name: juiceshop-usp-core-waap
  namespace: juiceshop
spec:
  webResources:
    configMap: core-waap-static-resources
    path: /resources/
    errorPages:
    - key: error5xx.html
      statusCode: 5xx
  crs:
    mode: DISABLED
  routes:
    - match:
        path: /
        pathType: PREFIX
      backend:
        address: juiceshop
        port: 8080
        protocol:
          selection: h1
```{{copy}}

(for this demo scenario the OWASP Core Rule Set has been disabled to focus on error pages and static file configuration)

<details>
<summary>example command output

```shell
corewaapservice.waap.core.u-s-p.ch/juiceshop-usp-core-waap created
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
NAMESPACE   NAME                       AGE
backend     juiceshop-usp-core-waap    59s
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
NAMESPACE   NAME                                       READY   STATUS    RESTARTS   AGE
backend     juiceshop-usp-core-waap-7849dbf5fd-4jt8c   1/1     Running   0          43s
```

</details>
<br />

>wait until the Core WAAP pod is running before trying to access the API in the next step (otherwise you'll get a HTTP 502 response)!

Continue accessing the [OWASP Juice Shop]({{TRAFFIC_HOST1_8080}}) via Core WAAP now (or consider the hidden solution in case you were not successful).

<details>
<summary>solution</summary>

First create the configmap:

```shell
kubectl apply -f error-configmap.yaml
```{{exec}}

Next, create the Core WAAP instance using:

```shell
kubectl apply -f juiceshop-core-waap.yaml
```{{exec}}

and wait for its readiness:

```shell
kubectl wait pods \
  -l app.kubernetes.io/name=usp-core-waap \
  -n juiceshop \
  --for='condition=Ready'
```{{exec}}

</details>
<br />

### Access via USP Core WAAP

The port forwarding was changed accordingly that the traffic to the [OWASP Juice Shop]({{TRAFFIC_HOST1_8080}}) is now routed **via USP Core WAAP**.

**Make sure to access the [profile page]({{TRAFFIC_HOST1_8080}}/profile) (while NOT being logged in) again...**

Did you notice the different error page?
Not only are sensitive application information hidden but also the style can be changed to match the Juice Shop layout.

### Inspect USP Core WAAP logs

Let's have a look at the logs!

```shell
kubectl logs \
  -n juiceshop \
  -l app.kubernetes.io/name=usp-core-waap \
  | grep '^{' | jq
```{{exec}}

<details>
<summary>example command output

```json
{
  "@timestamp": "2024-11-15T07:52:21.149Z",
  "request.id": "216dfcd7-0668-4e2a-b25d-edf911dfe3e5",
  "request.protocol": "HTTP/1.1",
  "request.method": "GET",
  "request.path": "/profile",
  "request.total_duration": "198",
  "request.body_bytes_received": "0",
  "response.status": "500",
  "response.details": "",
  "response.flags": "-",
  "response.body_bytes_sent": "407",
  "envoy.upstream.duration": "-",
  "envoy.upstream.host": "10.110.238.103:8080",
  "envoy.upstream.route": "-",
  "envoy.upstream.cluster": "core.waap.cluster.backend-juiceshop-8080-h1",
  "envoy.upstream.bytes_sent": "1034",
  "envoy.upstream.bytes_received": "401",
  "envoy.connection.id": "57",
  "client.address": "127.0.0.1:57716",
  "client.local_address": "127.0.0.1:8080",
  "client.direct_address": "127.0.0.1:57716",
  "host.hostname": "juiceshop-usp-core-waap-747b9748db-prq9r",
  "http.req_headers.referer": "-",
  "http.req_headers.useragent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36 Edg/130.0.0.0",
  "http.req_headers.authority": "juiceshop",
  "http.req_headers.forwarded_for": "-",
  "http.req_headers.forwarded_proto": "https"
}
```

</details>
<br />

That's it! As you see providing custom error pages is a powerful feature to hide specific http backend errors or streamline the error page layout across multiple backends!
