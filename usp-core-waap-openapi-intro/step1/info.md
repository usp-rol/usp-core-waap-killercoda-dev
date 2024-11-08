### Access plain swagger petstore (unprotected)

>wait until the console on the right side is ready before trying to access the API!

Access the petstore API (querying for a pet with ID 1) using the console on the right side:

>initially the petstore API will be access unprotected via localhost:8080

```shell
curl -s http://localhost:8080/api/pet/1 | jq '.'
```{{exec}}

<details>
<summary>example command output

```json
{
  "id": 1,
  "category": {
    "id": 2,
    "name": "Cats"
  },
  "name": "Cat 1",
  "photoUrls": [
    "url1",
    "url2"
  ],
  "tags": [
    {
      "id": 1,
      "name": "tag1"
    },
    {
      "id": 2,
      "name": "tag2"
    }
  ],
  "status": "available"
}
```

</details>
<br />

This will show the pet details (something familiar making "furrr" when happy...).

Next access the petstore API using an invalid format by an alphanumeric identifier instead of a numeric one:

```shell
curl -sv http://localhost:8080/api/pet/cat1
```{{exec}}

<details>
<summary>example command output

```shell
*   Trying 127.0.0.1:8080...
* TCP_NODELAY set
* Connected to localhost (127.0.0.1) port 8080 (#0)
> GET /api/pet/cat1 HTTP/1.1
> Host: localhost:8080
> User-Agent: curl/7.68.0
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 404 Not Found
< Date: Fri, 08 Nov 2024 09:42:18 GMT
< Access-Control-Allow-Origin: *
< Access-Control-Allow-Methods: GET, POST, DELETE, PUT
< Access-Control-Allow-Headers: Content-Type, api_key, Authorization
< Content-Type: application/json
< Transfer-Encoding: chunked
< Server: Jetty(9.2.9.v20150224)
<
* Connection #0 to host localhost left intact
{"code":404,"type":"unknown","message":"java.lang.NumberFormatException: For input string: \"cat1\""}
```

Note that the petstore API responded with a HTTP 404 (Not Found) response.
</details>
<br />

The output indicates that the API could not understand the request as shown by the message:

```json
{
  "code": 404,
  "type": "unknown",
  "message": "java.lang.NumberFormatException: For input string: \"cat1\""
}
```

Note however that this request already was processed by the backend and an attacker could do damage by this fact (like flooding the backend with incorrect request).

Now let's see how this can be **protected by USP Core WAAP** that invalid API calls are intercepted if they are not according to the configured schema!
