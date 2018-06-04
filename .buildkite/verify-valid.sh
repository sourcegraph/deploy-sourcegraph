#!/bin/bash

set -e
cd "$(dirname "${BASH_SOURCE[0]}")/.."

.buildkite/install-kubeval.sh

# Can't use xargs since kubeval ignores args if stdin is not a tty. xargs in
# busybox doesn't support -o to make stdin a tty.
kubeval $(find examples -path '*/generated/*.yaml')
kubeval $(find test-cases -path '*/generated/*.yaml')
