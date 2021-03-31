#!/usr/bin/env bash

cd "$(git rev-parse --show-toplevel)"
set -exuo pipefail

UPDATE_FILE="last-updated.txt"
rm "${UPDATE_FILE}" || true
date >"${UPDATE_FILE}"
