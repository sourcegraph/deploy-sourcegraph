#!/usr/bin/env bash

set -euo pipefail

REF="${REF:-"main"}"
NUM_COMMITS="${NUM_COMMITS:-"100"}"

API_SLUG="repos/sourcegraph/sourcegraph/commits"

function is_commit_green() {
  local commit="$1"

  # https://docs.github.com/en/rest/reference/repos#get-the-combined-status-for-a-specific-reference
  local state
  state="$(gh api "${API_SLUG}/${commit}/status" --jq '.state')"

  [[ "$state" == "success" ]]
}

function get_latest_commits() {
  local ref="$1"
  local num_commits="$2"

  # https://docs.github.com/en/rest/reference/repos#list-commits
  gh api "${API_SLUG}?sha=${ref}&per_page=${num_commits}" --jq '.[].sha'
}

LATEST_COMMITS=()
mapfile -t LATEST_COMMITS < <(get_latest_commits "${REF}" "${NUM_COMMITS}")

for c in "${LATEST_COMMITS[@]}"; do
  if is_commit_green "${c}"; then
    echo "${c}"
    exit 0
  fi
done

echo "no passing commit within last ${NUM_COMMITS} sourcegraph/sourcegraph commit(s)"
exit 1
