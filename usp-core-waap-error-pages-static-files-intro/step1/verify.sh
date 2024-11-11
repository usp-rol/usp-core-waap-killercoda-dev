#!/bin/bash

kubectl -n backend logs pod/website | grep 'GET /product_a.html'
