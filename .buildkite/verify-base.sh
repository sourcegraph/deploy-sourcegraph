#!/bin/bash

set -e
cd "$(dirname "${BASH_SOURCE[0]}")/.."

.buildkite/install-kubeval.sh

# Validate base yaml
find base -name '*.yaml' -exec kubeval {} +
