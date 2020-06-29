#!/bin/bash

# get all urls from the latest version of the bash scripts
latest=$(cd ../formats; ls -1d * | grep -E "V[0-9]" | tail -1)
urls=$(egrep -o -h 'https?://[^ ]+' ../formats/${latest}/*.sh | grep -o '^[^\[]*' | grep -v \$[a-zA-Z{])

# split into those urls that contain ( and those that dont
left_brackets=$(echo $urls | tr ' ' '\n' | grep '(')
_no_left_brackets=$(echo $urls | tr ' ' '\n' | grep -v '(')

#split into those that need trimming and those that dont
no_right_brackets=$(echo $_no_left_brackets | tr ' ' '\n' | grep -v ')')
_right_brackets=$(echo $_no_left_brackets | tr ' ' '\n' | grep ')')

# delete trailing right brackets
corrected_brackets=$(echo $_right_brackets | tr ' ' '\n' | sed s'/)$//')

_corrected_urls=$(echo "$corrected_brackets $left_brackets $no_right_brackets")
# strip any trailing periods from the corrected urls
corrected_urls=$(echo $_corrected_urls | tr ' ' '\n' | sed s'/\.$//')

./checkurls.sh ${corrected_urls}