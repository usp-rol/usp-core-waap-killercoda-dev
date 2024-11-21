#!/bin/bash

rm $0

clear

echo -n "Installing Juice Shop backend..."
while [ ! -f /tmp/.backend_installed ]; do
  echo -n '.'
  sleep 1;
done;
echo " done"
echo -n "Installing USP Core Waap Operator..."
while [ ! -f /tmp/.operator_installed ]; do
  echo -n '.'
  sleep 1;
done;
echo " done"
echo -n "Configuring CoreWaapService instance..."
while [ ! -f /tmp/.waap_installed ]; do
  echo -n '.'
  sleep 1;
done;
echo " done"
echo
