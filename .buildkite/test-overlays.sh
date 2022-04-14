#!/bin/bash

set -euxo pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")"/..

OVERLAYS=()
mapfile -d $'\0' OVERLAYS < <(find overlays -maxdepth 1 -type d ! -name '.*' ! -name 'bases' ! -name 'overlays' -printf '%f\n')

for o in "${OVERLAYS[@]}"; do
  ./overlays-generate-cluster.sh "${o}" generated-cluster-"${o}"
done
