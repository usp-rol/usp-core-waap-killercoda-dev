#!/bin/bash

kubectl -n swaggerapi exec pod/petstore -- /bin/bash -c "grep -E 'GET /.* 200 ' /var/log/*-requests.log"
