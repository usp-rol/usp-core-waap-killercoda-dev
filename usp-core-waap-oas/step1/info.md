### Access plain swagger petstore (unprotected)

>wait until the console on the right side is ready before trying to access the API!

[Access the petstore API]({{TRAFFIC_HOST1_8080}}) (querying for pet with ID 1) using your browser or cli using

```shell
curl -sv http://localhost:8080/api/pet/1
```{exec}

this will show the pet details.

Next access the API using an invalid format by using an alphanumeric identifier instead of a numeric one:

```shell
curl -sv http://localhost:8080/api/pet/cat1
```{exec}
