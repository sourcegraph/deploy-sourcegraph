#!/usr/bin/env bash

cd "$(git rev-parse --show-toplevel)"
set -euxo pipefail

create_pull_request() {
  gh pr create \
    --title "${TITLE}" \
    --body "${BODY}" \
    --head "${HEAD}" \
    --label "automerge"
}

set_pull_request_automerge() {
  local url="$1"

  gh pr merge "$url" \
    --auto \
    --squash
}

url=$(create_pull_request)
set_pull_request_automerge "$url" || true
