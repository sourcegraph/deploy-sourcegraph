#!/usr/bin/env bash

cd "$(git rev-parse --show-toplevel)"
set -euxo pipefail

function delete_tag() {
  local tag="$1"

  echo "--- Deleting local copy of ${tag}"
  git tag --delete "${tag}" || true # we don't care if we don't have a local copy

  echo "--- Deleting remote copy of ${tag}"
  git push origin :"${tag}" || true # we don't care if the remote tag doesn't exist
}

function create_tag() {
  local tag="$1"
  local commit="$2"

  echo "--- Tagging '${commit}' as ${tag}"
  git tag "${tag}" "${commit}"
}

function push_tag() {
  local tag="$1"

  echo "--- Pushing ${tag} to remote"
  git push origin "$1"
}

delete_tag "${TAG}"
create_tag "${TAG}" "${TARGET_COMMIT}"
push_tag "${TAG}"
