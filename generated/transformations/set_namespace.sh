#!/usr/bin/env bash

function set_namespace() {
  glob="$1"
  namespace="$2"
  filename="$3"

  if [[ $filename == $glob ]]; then
    cat - | yq w - "metadata.namespace" "$namespace"
    return
  fi
  cat -
}
