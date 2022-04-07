#!/usr/bin/env bash

set -e -o pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

command -v yj >/dev/null 2>&1 || .buildkite/install-yj.sh

find base -name "*.yaml" -not -name 'kustomization.yaml' -print0 | while IFS= read -r -d '' file; do
  if ! yj <"$file" | jq '.metadata.labels.deploy == "sourcegraph"' >/dev/null; then
    echo "$file does not contain .metadata.labels.deploy == sourcegraph"
    exit 1
  fi
done
