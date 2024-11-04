### Access plain swagger petstore (unprotected)

>wait until the console on the right side is ready before trying to access the API!

[Access the petstore API]({{TRAFFIC_HOST1_8080}}) (querying for pet with ID 1) using your browser or cli using

```shell
curl -s http://localhost:8080/api/pet/1 | jq '.'
```{{exec}}

This will show the pet details.

Next access the API using an invalid format by using an alphanumeric identifier instead of a numeric one:

```shell
curl -sv http://localhost:8080/api/pet/cat1
```{{exec}}

The output indicates, that the API could not understand the request as shown by

```json
{
  "code": 404,
  "type": "unknown",
  "message": "java.lang.NumberFormatException: For input string: \"cat1\""
}
```

Note however that this request already was processed by the backend and an attacker could do damage already by this fact (like flooding the backend with incorrect request).

Now let's see how this can be protected by USP Core WAAP that this API call is intercepted as it is not according the configured schema!
