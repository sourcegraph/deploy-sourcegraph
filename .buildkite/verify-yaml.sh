#!/bin/bash

set -ex
cd "$(dirname "${BASH_SOURCE[0]}")/.."

.buildkite/install-kubeval.sh

find base -name '*.yaml' -exec kubeval {} +
find configure -name '*.yaml' -exec kubeval {} +

.buildkite/verify-label.sh
