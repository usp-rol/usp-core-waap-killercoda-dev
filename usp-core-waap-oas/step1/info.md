### Access plain swagger petstore (unprotected)

>wait until the console on the right side is ready before trying to access the API!

>intially the petstore API will be access unprotected via localhost:8080

Access the petstore API (querying for a pet with ID 1) using the console on the right side:

```shell
curl -s http://localhost:8080/api/pet/1 | jq '.'
```{{exec}}

This will show the pet details (something familiar making "furrr" when happy...).

Next access the petstore API using an invalid format by an alphanumeric identifier instead of a numeric one:

```shell
curl -sv http://localhost:8080/api/pet/cat1
```{{exec}}

The output indicates, that the API could not understand the request as shown by the message:

```json
{
  "code": 404,
  "type": "unknown",
  "message": "java.lang.NumberFormatException: For input string: \"cat1\""
}
```

Note however that this request already was processed by the backend and an attacker could do damage by this fact (like flooding the backend with incorrect request).

Now let's see how this can be **protected by USP Core WAAP** that invalid API calls are intercepted if they are not according the configured schema!
