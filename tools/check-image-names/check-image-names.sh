#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../.."
set -euxo pipefail

ROOT="$(pwd)"
cd tools/check-image-names

echo "--- Check to see if all manifests contain valid image names"
go run check-image-names.go "${ROOT}"/base
