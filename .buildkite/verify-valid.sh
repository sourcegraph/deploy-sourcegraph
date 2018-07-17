#!/bin/bash

set -e
cd "$(dirname "${BASH_SOURCE[0]}")/.."

.buildkite/install-kubeval.sh
.buildkite/install-kustomize.sh

kustomize build base | kubeval