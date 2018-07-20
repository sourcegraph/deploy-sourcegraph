#!/bin/bash

set -e
cd "$(dirname "${BASH_SOURCE[0]}")/.."

.buildkite/install-kubeval.sh
.buildkite/verify-label.sh

# Validate base yaml
find base -name '*.yaml' -exec kubeval {} +

.buildkite/verify-label.sh
