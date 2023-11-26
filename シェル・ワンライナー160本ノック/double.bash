#!/bin/bash

if [ "$1" = "" ]; then
    read n
else
    n="$1"
fi

echo $((n * 2))
