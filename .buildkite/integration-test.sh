#!/usr/bin/env bash

set -ex

cd $(dirname "${BASH_SOURCE[0]}")/..

export DEPLOY_SOURCEGRAPH_ROOT=$(pwd)
export TEST_GCP_PROJECT=sourcegraph-server
export TEST_GCP_ZONE=us-central1-a
export TEST_GCP_USERNAME=buildkite@sourcegraph-dev.iam.gserviceaccount.com
export BUILD_CREATOR=$BUILDKITE_BUILD_CREATOR

maybe_short_flag=""

if [[ -z $BUILDKITE_PULL_REQUEST || $BUILDKITE_PULL_REQUEST == "false" ]]; then
    maybe_short_flag="-short"
fi 

go test ./... -v -timeout 25m ${maybe_short_flag}
