#!/usr/bin/env bash

cd $(dirname "${BASH_SOURCE[0]}")/..
set -euxo pipefail

cd tests/integration/fresh/step1

pnpm install

pnpm prettier-check
