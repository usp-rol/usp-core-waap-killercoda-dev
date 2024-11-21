### Inspect USP Core WAAP logs

Let's have a look at the logs!

```shell
kubectl logs \
  -n juiceshop \
  -l app.kubernetes.io/name=usp-core-waap \
  --tail=-1 \
  | grep "\[critical\]\[wasm\]"
```{{exec}}

<details>
<summary>example command output

```shell
[2024-11-21 10:14:15.017][15][critical][wasm] [source/extensions/common/wasm/context.cc:1204] wasm log core.waap.listener.filters.http.httpFilter.wasm.coraza.config coraza-vm: {"request.path":"/socket.io/?EIO=4\u0026transport=polling\u0026t=PDEDm7q\u0026sid=Q_d8fQ7HSAYmjI_kAAAF","crs.violated_rule":{"id":920420,"category":"REQUEST-920-PROTOCOL-ENFORCEMENT","severity":"CRITICAL","data":"|text/plain|","message":"Request content type is not allowed by policy","matched_data":"REQUEST_HEADERS","matched_data_name":"content-type","tags":["application-multi","language-multi","platform-multi","attack-protocol","paranoia-level/1","OWASP_CRS","capec/1000/255/153","PCI/12.1"]},"client.address":"127.0.0.1","transaction.id":"xpIaKdMfdmgZPBdBZWM","crs.version":"OWASP_CRS/4.3.0","request.id":"ce104af8-283d-4c8b-a3bf-609692267f57"}
[2024-11-21 10:14:15.026][15][critical][wasm] [source/extensions/common/wasm/context.cc:1204] wasm log core.waap.listener.filters.http.httpFilter.wasm.coraza.config coraza-vm: {"request.path":"/socket.io/?EIO=4\u0026transport=polling\u0026t=PDEDm7q\u0026sid=Q_d8fQ7HSAYmjI_kAAAF","crs.violated_rule":{"id":949111,"category":"REQUEST-949-BLOCKING-EVALUATION","severity":"EMERGENCY","data":"","message":"Inbound Anomaly Score Exceeded in phase 1 (Total Score: 5)","matched_data":"TX","matched_data_name":"blocking_inbound_anomaly_score","tags":["anomaly-evaluation","OWASP_CRS"]},"client.address":"127.0.0.1","transaction.id":"xpIaKdMfdmgZPBdBZWM","crs.version":"OWASP_CRS/4.3.0","request.id":"ce104af8-283d-4c8b-a3bf-609692267f57"}
[2024-11-21 10:14:15.401][15][critical][wasm] [source/extensions/common/wasm/context.cc:1204] wasm log core.waap.listener.filters.http.httpFilter.wasm.coraza.config coraza-vm: {"request.path":"/rest/user/login","crs.violated_rule":{"id":942100,"category":"REQUEST-942-APPLICATION-ATTACK-SQLI","severity":"CRITICAL","data":"Matched Data: s\u00261; found within ARGS_POST:json.email: ' OR true;","message":"SQL Injection Attack Detected via libinjection","matched_data":"ARGS_POST","matched_data_name":"json.email","tags":["application-multi","language-multi","platform-multi","attack-sqli","paranoia-level/1","OWASP_CRS","capec/1000/152/248/66","PCI/6.5.2"]},"client.address":"127.0.0.1","transaction.id":"HIkttRpzYXYhzkhUyMl","crs.version":"OWASP_CRS/4.3.0","request.id":""}
[2024-11-21 10:14:15.405][15][critical][wasm] [source/extensions/common/wasm/context.cc:1204] wasm log core.waap.listener.filters.http.httpFilter.wasm.coraza.config coraza-vm: {"request.path":"/rest/user/login","crs.violated_rule":{"id":949110,"category":"REQUEST-949-BLOCKING-EVALUATION","severity":"EMERGENCY","data":"","message":"Inbound Anomaly Score Exceeded (Total Score: 5)","matched_data":"TX","matched_data_name":"blocking_inbound_anomaly_score","tags":["anomaly-evaluation","OWASP_CRS"]},"client.address":"127.0.0.1","transaction.id":"HIkttRpzYXYhzkhUyMl","crs.version":"OWASP_CRS/4.3.0","request.id":""}
[2024-11-21 10:14:15.485][15][critical][wasm] [source/extensions/common/wasm/context.cc:1204] wasm log core.waap.listener.filters.http.httpFilter.wasm.coraza.config coraza-vm: {"request.path":"/socket.io/?EIO=4\u0026transport=polling\u0026t=PDEDnrH\u0026sid=sK5_0cUWUSrqisfuAAAG","crs.violated_rule":{"id":920420,"category":"REQUEST-920-PROTOCOL-ENFORCEMENT","severity":"CRITICAL","data":"|text/plain|","message":"Request content type is not allowed by policy","matched_data":"REQUEST_HEADERS","matched_data_name":"content-type","tags":["application-multi","language-multi","platform-multi","attack-protocol","paranoia-level/1","OWASP_CRS","capec/1000/255/153","PCI/12.1"]},"client.address":"127.0.0.1","transaction.id":"yxVTJkWNRxjzsFWuXDV","crs.version":"OWASP_CRS/4.3.0","request.id":"98381a37-fb77-4b0a-9a7a-e527db186ccc"}
[2024-11-21 10:14:15.503][15][critical][wasm] [source/extensions/common/wasm/context.cc:1204] wasm log core.waap.listener.filters.http.httpFilter.wasm.coraza.config coraza-vm: {"request.path":"/socket.io/?EIO=4\u0026transport=polling\u0026t=PDEDnrH\u0026sid=sK5_0cUWUSrqisfuAAAG","crs.violated_rule":{"id":949111,"category":"REQUEST-949-BLOCKING-EVALUATION","severity":"EMERGENCY","data":"","message":"Inbound Anomaly Score Exceeded in phase 1 (Total Score: 5)","matched_data":"TX","matched_data_name":"blocking_inbound_anomaly_score","tags":["anomaly-evaluation","OWASP_CRS"]},"client.address":"127.0.0.1","transaction.id":"yxVTJkWNRxjzsFWuXDV","crs.version":"OWASP_CRS/4.3.0","request.id":"98381a37-fb77-4b0a-9a7a-e527db186ccc"}
```

</details>
<br />

Notice the high amount of `"request.path":"/socket.io/?...` requests being blocked?

Having a closer look into the logs specifically filtering for `/socket.io` we get more details:

```shell
kubectl logs \
  -n juiceshop \
  -l app.kubernetes.io/name=usp-core-waap \
  | grep "/socket.io"
```{{exec}}

<details>
<summary>example command output

```shell
[2024-11-21 12:11:07.801][60][critical][wasm] [source/extensions/common/wasm/context.cc:1204] wasm log core.waap.listener.filters.http.httpFilter.wasm.coraza.config coraza-vm: {"request.path":"/socket.io/?EIO=4\u0026transport=polling\u0026t=PDEeXwM\u0026sid=s7SRPmMFt70kLpIiAAAI","crs.violated_rule":{"id":920420,"category":"REQUEST-920-PROTOCOL-ENFORCEMENT","severity":"CRITICAL","data":"|text/plain|","message":"Request content type is not allowed by policy","matched_data":"REQUEST_HEADERS","matched_data_name":"content-type","tags":["application-multi","language-multi","platform-multi","attack-protocol","paranoia-level/1","OWASP_CRS","capec/1000/255/153","PCI/12.1"]},"client.address":"172.18.0.1","transaction.id":"eLseFMkYwydsNfseZcj","crs.version":"OWASP_CRS/4.3.0","request.id":"b903d201-701d-440f-9232-c97d00ceb9ab"}
```

</details>
<br />

The log messages is split into two parts: First part prior to `coraza-vm:` containing the generic envoy log information indicating what module is taking action, which in our use-case [coraza](https://github.com/corazawaf/coraza) web application firewall module and the second parts which is the actual payload log as JSON.

Using the following command we parse the JSON output and hereby as humans have better insight into the actual action:

```shell
kubectl logs \
  -n juiceshop \
  -l app.kubernetes.io/name=usp-core-waap \
  | grep "coraza-vm.*/socket.io" \
  | sed -e 's/.* coraza-vm: //' \
  | jq
```{{exec}}

<details>
<summary>example command output

```json
{
  "request.path": "/socket.io/?EIO=4&transport=polling&t=PDEjrVo&sid=HqpIjqKPyn_lf7d4AAN0",
  "crs.violated_rule": {
    "id": 920420,
    "category": "REQUEST-920-PROTOCOL-ENFORCEMENT",
    "severity": "CRITICAL",
    "data": "|text/plain|",
    "message": "Request content type is not allowed by policy",
    "matched_data": "REQUEST_HEADERS",
    "matched_data_name": "content-type",
    "tags": [
      "application-multi",
      "language-multi",
      "platform-multi",
      "attack-protocol",
      "paranoia-level/1",
      "OWASP_CRS",
      "capec/1000/255/153",
      "PCI/12.1"
    ]
  },
  "client.address": "172.18.0.1",
  "transaction.id": "ZelukCRiZUGvQRXwTIC",
  "crs.version": "OWASP_CRS/4.3.0",
  "request.id": "e58553ec-d1cc-476d-b48b-f38d8393835d"
}
{
  "request.path": "/socket.io/?EIO=4&transport=polling&t=PDEjrVo&sid=HqpIjqKPyn_lf7d4AAN0",
  "crs.violated_rule": {
    "id": 949111,
    "category": "REQUEST-949-BLOCKING-EVALUATION",
    "severity": "EMERGENCY",
    "data": "",
    "message": "Inbound Anomaly Score Exceeded in phase 1 (Total Score: 5)",
    "matched_data": "TX",
    "matched_data_name": "blocking_inbound_anomaly_score",
    "tags": [
      "anomaly-evaluation",
      "OWASP_CRS"
    ]
  },
  "client.address": "172.18.0.1",
  "transaction.id": "ZelukCRiZUGvQRXwTIC",
  "crs.version": "OWASP_CRS/4.3.0",
  "request.id": "e58553ec-d1cc-476d-b48b-f38d8393835d"
}
```

</details>
<br />

The field `crs.violated_rule` indicates what Core Rule Set RuleId has triggered and is required to add an exception for.

> the Rule IDs in the 949... range are the blocking condition rules and are not of interest, in our case the Rule ID 920420 (Protocol enforcement) is!

We want these `/socket.io` requests to succeed (in our use-case they are a `false positive`) and therefore we add an exeption rule to the core-waap CRS configuration using `requestRuleExceptions`:

```yaml
...
spec:
  crs:
    requestRuleExceptions:
    - ruleId: 920420
      requestPartType: "REQUEST_HEADERS"
      requestPartName: "content-type"
      regEx: true
      location: "socket.io/*"
      metadata:
        comment: "Enable socket.io requests"
        date: "2024-11-21"
        createdBy: killercoda-user
...
```

>detailed information about the rule 920420 are available via [Core Rule Set github repository](https://github.com/coreruleset/coreruleset/blob/main/rules/REQUEST-920-PROTOCOL-ENFORCEMENT.conf)

Apply the updated `CoreWaapService` prepared for you using:

```shell
kubectl apply -f juiceshop-core-waap.yaml
```{{exec}}

<details>
<summary>example command output

```shell
corewaapservice.waap.core.u-s-p.ch/juiceshop-usp-core-waap configured
```

</details>
<br />

Now after having reconfigure the `CoreWaapService` instance wait for its reconfiguration (indicated by the log) and observe the `socket.io` request denial disappear:

```shell
kubectl logs \
  -n juiceshop \
  -l app.kubernetes.io/name=usp-core-waap
  -f 
```{{exec}}

That's it! ...
