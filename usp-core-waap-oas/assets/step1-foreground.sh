#!/bin/bash

rm $0

clear

echo -n "Installing scenario..."
while [ ! -f /tmp/.petstore-finished ]; do
  echo -n '.'
  sleep 1;
done;
echo " done"
echo "you should now be able to access the petstore API using 'curl -v http://localhost:8080/' via cli or the browser link on the left pane"

echo
