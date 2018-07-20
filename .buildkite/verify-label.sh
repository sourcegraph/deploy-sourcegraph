#!/bin/bash

set -x

cd "$(dirname "${BASH_SOURCE[0]}")/.."

if find base configure -name "*.yaml" -exec sh -c "cat {} | yj | jq --raw-output '.metadata.labels.deploy'" \; | grep -v sourcegraph; then
    echo "> There exists a yaml file in base/ or configure/ that does not contain .metadata.labels.deploy == sourcegraph"
    echo "> Run the following command to fix:"
    echo "find base/ configure/ -name \"*.yaml\" -exec sh -c \"cat {} | yj | jq '.metadata.labels.deploy = \\\"sourcegraph\\\"' | jy -o {}\" \;"

    exit 1
fi
