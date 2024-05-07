#!/bin/bash

# @copyright Copyright (c) 2024 Christian Lück, taken from https://github.com/clue/framework-x/pull/3 with permission

base=${1:-http://clue.localhost/}
base=${base%/}

for i in {1..600}
do
   out=$(curl -v -X PROBE $base/ 2>&1) && exit 0 || echo -n .
   sleep 0.1
done

echo
echo "$out"
exit 1
