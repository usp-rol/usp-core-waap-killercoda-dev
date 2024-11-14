#!/bin/bash

kubectl -n juiceshop logs pod/juiceshop | grep 'GET /profile'
