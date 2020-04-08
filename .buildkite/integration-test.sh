#!/usr/bin/env bash

set -ex

cd "$(dirname "${BASH_SOURCE[0]}")"/..

DEPLOY_SOURCEGRAPH_ROOT=$(pwd)
export DEPLOY_SOURCEGRAPH_ROOT

export TEST_GCP_PROJECT=sourcegraph-server
export TEST_GCP_ZONE=us-central1-a
export TEST_GCP_USERNAME=buildkite@sourcegraph-dev.iam.gserviceaccount.com

BUILD_CREATOR="$(echo "${BUILDKITE_BUILD_CREATOR}" | tr ' /@.' '_' | tr '[:upper:]' '[:lower:]')"
export BUILD_CREATOR

GENERATED_BASE=$(mktemp -d)
export GENERATED_BASE

cleanup() {
    echo "--- Cleaning up test artifacts"
    rm -rf "${GENERATED_BASE}"
}
trap cleanup EXIT

kustomize build overlays/non-root-create-cluster -o "${GENERATED_BASE}"

TEST_ARGS=("test" "-timeout" "25m")

if [[ "${VERBOSE:-"false"}" == "true" ]]; then
    TEST_ARGS+=("-v")
fi

TEST_ARGS+=("./...")

echo "--- Running integration tests"

go "${TEST_ARGS[@]}"
