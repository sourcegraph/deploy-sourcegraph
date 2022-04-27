#!/usr/bin/env bash

set -euf -o pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

BUILD_DIR=$(mktemp -d)
export BUILD_DIR

cleanup() {
  rm -rf "${BUILD_DIR}"
}
trap cleanup EXIT

cp -R overlays "${BUILD_DIR}"
cp -R base "${BUILD_DIR}"/overlays/bases/deployments/base
cp -R base "${BUILD_DIR}"/overlays/bases/rbac-roles/base
cp -R base "${BUILD_DIR}"/overlays/bases/pvcs/base
cp -R configure "${BUILD_DIR}"/overlays/bases/jobs/configure

mkdir -p $2

kustomize build "${BUILD_DIR}"/overlays/$1 -o $2
