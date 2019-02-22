#!/bin/bash

set -ex

cd $(dirname "${BASH_SOURCE[0]}")/..


.buildkite/install-yaml2json.sh

missing_labels=$(find base -name "*.yaml" -print0 | xargs -0L1 -I {} sh -c "cat {} | yaml2json | jq --exit-status -f .buildkite/rbac.jq > /dev/null || echo {}")

if [ ! -z "${missing_labels}" ]; then
    echo "> Please add 'metadata.labels.category: rbac' to the following files:"
    echo "${missing_labels}"
    exit 1 
fi
