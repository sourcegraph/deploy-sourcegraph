#!/bin/bash

set -ex

cd $(dirname "${BASH_SOURCE[0]}")/..

# Ignore configure/ingress-nginx since it won't be deployed by CI regularly
missing_labels=$(find base configure -not \( -path configure/ingress-nginx -prune \) -name "*.yaml" -print0 | xargs -0L1 -I {} sh -c "cat {} | yaml2json | jq -s --exit-status -f .buildkite/rbac.jq > /dev/null || echo {}")

if [ ! -z "${missing_labels}" ]; then
  {
    echo "> Some files that declare RBAC-related resources are missing the 'category: rbac' label."
    echo "> The 'category: rbac' label allows users to filter out these resources when applying them to a K8s cluster if they lack sufficient permissions."
    echo "> Please add 'metadata.labels.category: rbac' to the following files:"
    echo "${missing_labels}"
  } 2>/dev/null
  exit 1
fi
