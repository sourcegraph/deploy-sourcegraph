#!/bin/bash

set -ex
cd "$(dirname "${BASH_SOURCE[0]}")/.."

if grep -r --include=\*.Deployment.yaml -H -e requests: -A 2 .; then
    echo "Resource requests should be converted to limits."
    exit 1
fi
