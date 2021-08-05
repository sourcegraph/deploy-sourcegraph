#!/usr/bin/env bash

set -euf -o pipefail
echo "running in $(dirname "${BASH_SOURCE[0]}")"
cd "$(dirname "${BASH_SOURCE[0]}")"

for arg in "$@"; do
  if [ "$arg" == "--help" ] || [ "$arg" == "-h" ]; then
    echo 'Usage: ./set-repo-registry.sh REGISTRY REPO TAG'
    exit 1
  fi
done

registry="${1:-index.docker.io}"
repository="${2:-sourcegraph}"
tag="${3:-v.3.30.3}"

for image_str in $(rg -e "image:\s(\S*)" ../../base/ --trim -r '$1' | cut -d ':' -f 2); do
  if [[ "$image_str" == */* ]]; then # must contain atleast one "/"
    echo "$image_str"
    IFS='/' read -r -a array <<<"$image_str"
    set -x
    kustomize edit set image "$image_str"="${registry}"/"${repository}"/"${array[-1]}":"${tag}"
    # also possible to use kustomzie to set the sha256
  fi
done
