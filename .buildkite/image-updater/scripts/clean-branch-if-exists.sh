#!/usr/bin/env bash

cd "$(git rev-parse --show-toplevel)"
set -euxo pipefail

branch_exists_on_remote() {
  git ls-remote --exit-code --heads origin "$1"
}

delete_local_branch() {
  git branch --delete --force "$1"
}

delete_remote_branch() {
  git push origin --delete "$1"
}

TARGET_BRANCH="${TARGET_BRANCH:-"update-docker-images/everything-not-gitserver"}"

delete_local_branch "${TARGET_BRANCH}" || true # we don't care if the branch doesn't exist locally

if branch_exists_on_remote "${TARGET_BRANCH}"; then
  delete_remote_branch "${TARGET_BRANCH}"
fi
