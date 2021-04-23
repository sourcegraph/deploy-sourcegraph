#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../.."
set -euxo pipefail

echo "--- Check to see if semver tag are set if release branch"
go run .buildkite/verify-release/verify-release.go -verbose=true base/
