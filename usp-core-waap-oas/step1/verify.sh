#!/bin/bash

kubectl -n swaggerapi exec pod/petstore -- /bin/bash -c "grep -E 'GET /api/pet/cat1 .* 200 ' /var/log/*-requests.log"
