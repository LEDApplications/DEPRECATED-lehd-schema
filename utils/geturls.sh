#!/bin/bash
latest=$(cd ../formats; ls -1d * | grep -E "V[0-9]" | tail -1)
urls=$(egrep -o -h 'https?://[^ ]+' ../formats/${latest}/*.sh | grep -o '^[^\[]*' | grep -v \$[a-zA-Z{])

./checkurls.sh ${urls}