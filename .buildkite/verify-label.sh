#!/bin/bash

set -ex

cd "$(dirname "${BASH_SOURCE[0]}")/.."

.buildkite/install-yj.sh

if find base -name "*.yaml" \( ! -name kustomization.yaml \) -exec sh -c "cat {} | yj | jq --raw-output '.metadata.labels.deploy'" \; | tee /tmp/deploy-label | grep -v sourcegraph; then
	echo "> There exists a yaml file in base/ that does not contain .metadata.labels.deploy == sourcegraph"
	echo "> Run the following command to fix:"
	echo "find base/ -name \"*.yaml\" -exec sh -c \"cat {} | yj | jq '.metadata.labels.deploy = \\\"sourcegraph\\\"' | jy -o {}\" \;"

	exit 1
fi
