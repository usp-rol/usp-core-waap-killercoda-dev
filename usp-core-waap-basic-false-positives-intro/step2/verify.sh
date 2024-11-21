#!/bin/bash

LOGS=$(kubectl logs -n juiceshop -l app.kubernetes.io/name=usp-core-waap | grep "/socket.io" | wc -l)
test $LOGS -eq 0
