#!/bin/bash

set -eu
pushd "$(dirname "${BASH_SOURCE[0]}")"/..

OVERLAYS=()
mapfile -t OVERLAYS < <(find overlays -maxdepth 1 -type d ! -name '.*' ! -name 'bases' ! -name 'overlays' -printf '%f\n')

for O in "${OVERLAYS[@]}"; do
  echo "<<<< GENERATING ${O} OVERLAY >>>>>"
  DIR=generated-cluster-${O}
  mkdir "${DIR}"
  ./overlay-generate-cluster.sh "${O}" "${DIR}"
  rm -rf "${DIR}"
done
