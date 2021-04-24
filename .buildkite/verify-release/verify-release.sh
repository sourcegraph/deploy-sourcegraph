#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../.."
set -euxo pipefail

ROOT="$(pwd)"
cd .buildkite/verify-release

echo "--- Check to see if semver tag are set in release branch"
# go run . -verbose=true "${ROOT}"/base
go run . -verbose=true /Users/ggilmore/dev/go/src/github.com/sourcegraph/deploy/base/syntect-server/syntect-server.Deployment.yaml