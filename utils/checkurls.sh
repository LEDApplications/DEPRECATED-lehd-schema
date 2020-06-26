#!/bin/bash

for url in $@
do
    urlstatus=$(curl -o /dev/null --silent --head --write-out '%{http_code}' "$url" )
    if [ $urlstatus -ne 200 ]; then
      echo "$url  $urlstatus"
    fi
done