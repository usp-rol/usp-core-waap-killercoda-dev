#!/bin/bash

kubectl logs -n backend -l app.kubernetes.io/name=usp-core-waap | grep 'product_a.html'
