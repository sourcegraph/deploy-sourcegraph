#!/bin/bash

set -e
cd "$(dirname "${BASH_SOURCE[0]}")/.."

if [[ $(grep -r --include=\*.Deployment.yaml -L limits: .) ]]; then
    echo "All deployments should have configured resource limits."
    exit 1
fi
