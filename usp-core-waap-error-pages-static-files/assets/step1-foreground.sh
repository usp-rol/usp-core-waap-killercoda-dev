#!/bin/bash

rm $0

clear

echo -n "Installing scenario..."
while [ ! -f /tmp/.background-finished ]; do
  echo -n '.'
  sleep 1;
done;
echo " done"
echo
