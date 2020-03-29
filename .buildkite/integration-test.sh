#!/usr/bin/env bash

set -ex

cd $(dirname "${BASH_SOURCE[0]}")/..

export DEPLOY_SOURCEGRAPH_ROOT=$(pwd)
export TEST_GCP_PROJECT=sourcegraph-server
export TEST_GCP_ZONE=us-central1-a
export TEST_GCP_USERNAME=buildkite@sourcegraph-dev.iam.gserviceaccount.com
export BUILD_CREATOR=$BUILDKITE_BUILD_CREATOR

go test ./... -v -timeout 25m ${maybe_short_flag}

${DEPLOY_SOURCEGRAPH_ROOT}/tests/integration/restricted/test.sh

