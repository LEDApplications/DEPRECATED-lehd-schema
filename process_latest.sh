#!/bin/bash

# config
FILES=$(pwd $0)/formats
GLOBALSH=write_all.sh

# gh-pages gets tagged with a draft, master gets official
current_branch=$(git rev-parse --abbrev-ref HEAD)
case $current_branch in
    master)
        VERSION=official
        ;;
    *)
        VERSION=draft
        ;;
esac

# find latest
[[ -z $2 ]] && latest=$(cd formats; ls -1d * | grep -E "V[0-9]" | tail -1) || latest=$2

# diagnostics
echo "========================================="
echo "Processing $latest with output=$VERSION"
echo "========================================="

# do stuff
cd $FILES/$latest
./$GLOBALSH $VERSION
