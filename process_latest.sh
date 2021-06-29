#!/bin/bash

# config
FILES=$(pwd $0)/formats
GLOBALSH=write_all.sh

# passing in 'travis', as done during build gets tagged as draft
# anything else is considered an official build
case $1 in
    travis)
        VERSION=draft
        ;;
    *)
        VERSION=official
        ;;
esac

# find latest
latest=$(cd formats; ls -1d * | grep -E "V[0-9]" | tail -1)

# diagnostics
echo "========================================="
echo "Processing $latest with output=$VERSION"
echo "========================================="

# check for byte order mark in data files
bomfiles=$(for f in ./formats/${latest}/*.csv; do file $f; done | grep BOM)
if [[ $bomfiles ]]; then
  echo ""
  echo "========================================="
  echo "Warning: UTF-8 Unicode (with BOM) encoded file found"
  echo "$bomfiles"
  echo "========================================="
  echo ""
fi

# do stuff
cd $FILES/$latest
./$GLOBALSH $VERSION
