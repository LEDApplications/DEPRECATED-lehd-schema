#!/bin/bash

for url in $@
do
    urlstatus=$(curl -o /dev/null --silent --head --write-out '%{http_code}' "$url" )
    if [ $urlstatus -ne 200 ] && [ $urlstatus -ne 302 ] && [ $urlstatus -ne 301 ]; then
      echo "$url  (status: $urlstatus)"
    fi
done