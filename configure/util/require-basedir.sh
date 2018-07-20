#!/bin/bash

set -e

cd "$(dirname "${BASH_SOURCE[0]}")/../.."

if [ -z ${BASEDIR+x} ]; then
    read -p "Directory that contains the Kubernetes config to be configured [required]: " BASEDIR
fi

if [ -z "$BASEDIR" ]; then
    echo "BASEDIR is required"
    exit 1
fi

