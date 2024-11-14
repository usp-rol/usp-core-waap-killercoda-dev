#!/bin/bash

rm $0

clear

echo -n "Installing scenario..."
while [ ! -f /tmp/.petstore-finished ]; do
  echo -n '.'
  sleep 1;
done;
echo " done"
echo
