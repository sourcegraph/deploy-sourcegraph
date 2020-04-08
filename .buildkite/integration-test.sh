#!/usr/bin/env bash

set -ex

cd $(dirname "${BASH_SOURCE[0]}")/..

export DEPLOY_SOURCEGRAPH_ROOT=$(pwd)
export TEST_GCP_PROJECT=sourcegraph-server
export TEST_GCP_ZONE=us-central1-a
export TEST_GCP_USERNAME=buildkite@sourcegraph-dev.iam.gserviceaccount.com
export BUILD_CREATOR="$(echo $BUILDKITE_BUILD_CREATOR | tr ' /@.' '_' | tr 'A-Z' 'a-z')"

export GENERATED_BASE=`mktemp -d`

kustomize build overlays/non-root-create-cluster -o ${GENERATED_BASE}

TEST_ARGS=( "test" "-timeout" "25m")

if [[ "${VERBOSE:-"false"}" == "true" ]]; then
    TEST_ARGS+=( "-v" )
fi

TEST_ARGS+=( "./..." )

echo "--- Running integration tests"

go "${TEST_ARGS[@]}"
