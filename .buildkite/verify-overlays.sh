#!/bin/bash

set -eux
pushd "$(dirname "${BASH_SOURCE[0]}")"/..

OVERLAYS=()
mapfile -t OVERLAYS < <(find overlays -maxdepth 1 -type d ! -name '.*' ! -name 'bases' ! -name 'overlays' -printf '%f\n')

for o in "${OVERLAYS[@]}"; do
  echo "<<<< GENERATING ${o} OVERLAYS >>>>>"
  DIR=generated-cluster-${o}
  mkdir "${DIR}"
  ./overlay-generate-cluster.sh "${o}" "${DIR}"
  rm -rf "${DIR}"
done
