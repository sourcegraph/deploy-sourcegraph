#!/usr/bin/env bash

set -euxo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
ROOT="$(pwd)"

pushd tools/check-image-names

echo "--- Check to see if all manifests contain valid image names"
go run check-image-names.go "${ROOT}"/base
