#!/usr/bin/env bash

cd "$(git rev-parse --show-toplevel)"
set -euxo pipefail

export OUTPUT_DIR="${OUTPUT_DIR:-".buildkite/image-updater"}"
export SCRIPTS_DIR="${OUTPUT_DIR}/scripts"

rm -rf "${OUTPUT_DIR}" || true
mkdir -p "${SCRIPTS_DIR}"

PIPELINE_FILE="./ci/pipeline.dhall"

# write scripts
echo "(${PIPELINE_FILE}).Scripts" | dhall to-directory-tree --output "${SCRIPTS_DIR}"
fd --extension "sh" . "${SCRIPTS_DIR}" --exec chmod +x '{}'

# write buildkite pipeline
echo "(${PIPELINE_FILE}).Pipeline" | dhall-to-yaml --generated-comment --output="${OUTPUT_DIR}/pipeline.yaml"
