#!/usr/bin/env bash

set -exuo pipefail

TMP="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP"
}
trap cleanup EXIT

git clone --depth 1 https://github.com/sourcegraph/distribution-tools "${TMP}"
cd "${TMP}"

asdf install

go build -o srcimage main.go
chmod +x srcimage
mv srcimage /usr/local/bin
