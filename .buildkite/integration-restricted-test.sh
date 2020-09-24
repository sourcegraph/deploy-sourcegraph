#!/usr/bin/env bash

set -ex

cd "$(dirname "${BASH_SOURCE[0]}")"/..

export TEST_GCP_PROJECT=sourcegraph-ci
export TEST_GCP_ZONE=us-central1-a
# TODO(uwedeportivo): fix to comply with label restrictions (lowercase, less than 60, only _ and maybe others)
# export BUILD_CREATOR="$(echo "$BUILDKITE_BUILD_CREATOR" | tr ' @./' '_' | tr 'A-Z' 'a-z')"
export BUILD_CREATOR=unknown
export BUILD_UUID=$BUILDKITE_BUILD_ID
# TODO(uwedeportivo): fix to comply with label restrictions (lowercase, less than 60, only _ and maybe others)
# export BUILD_BRANCH="$(echo $BUILDKITE_BRANCH | tr ' @./' '_' | tr 'A-Z' 'a-z')"
export BUILD_BRANCH=unknown

./tests/integration/restricted/test.sh
