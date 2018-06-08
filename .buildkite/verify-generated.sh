#!/bin/bash

set -e
cd "$(dirname "${BASH_SOURCE[0]}")/.."

.buildkite/install-helm.sh

# Ensure examples are re-generated.

echo "Ensuring examples are consistent with Helm chart..."

export GIT_PAGER=cat
working_copy_hash=$((git diff; git status) | (md5sum || md5) 2> /dev/null)
examples/generate.sh
test-cases/generate.sh
new_working_copy_hash=$((git diff; git status) | (md5sum || md5) 2> /dev/null)

if [[ ${working_copy_hash} = ${new_working_copy_hash} ]]; then
    echo "SUCCESS: generate did not change the working copy"
else
    echo "FAIL: generate changed the working copy"
    git diff
    git status
    exit 2
fi
