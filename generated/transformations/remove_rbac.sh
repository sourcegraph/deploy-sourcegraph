#!/usr/bin/env bash

function remove_rbac() {
  if [[ $1 == *"/rbac-roles/"* ]]; then
    # echo "removed $1" 1>&2
    echo ""
    return
  fi
  cat -
}
