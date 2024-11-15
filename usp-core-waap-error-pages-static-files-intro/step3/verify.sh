#!/bin/bash

kubectl logs -n juiceshop -l app.kubernetes.io/name=usp-core-waap | grep 'product_a.html'
