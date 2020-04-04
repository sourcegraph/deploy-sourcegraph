#!/usr/bin/env bash

set -ex

cd $(dirname "${BASH_SOURCE[0]}")/..

export DEPLOY_SOURCEGRAPH_ROOT=$(pwd)
export TEST_GCP_PROJECT=sourcegraph-server
export TEST_GCP_ZONE=us-central1-a
export TEST_GCP_USERNAME=buildkite@sourcegraph-dev.iam.gserviceaccount.com
export BUILD_CREATOR=$BUILDKITE_BUILD_CREATOR
export BUILD_UUID=$BUILDKITE_BUILD_ID
export BUILD_BRANCH=$BUILDKITE_BRANCH

${DEPLOY_SOURCEGRAPH_ROOT}/tests/integration/restricted/test.sh

