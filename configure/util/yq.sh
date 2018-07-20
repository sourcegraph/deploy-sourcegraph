#!/bin/bash

set -e

if [ -z ${INFILE+x} ]; then
    echo "INFILE required"
    exit 1
fi

if [ -z ${QUERY+x} ]; then
    echo "QUERY required"
    exit 1
fi

if [ -z ${OUTFILE+x} ]; then
    echo "OUTFILE required"
    exit 1
fi

cat $INFILE | yj | jq "$QUERY" | jy -o $OUTFILE
