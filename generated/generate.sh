#!/usr/bin/env bash

set -euf -o pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
export GENERATED_DIR="generated-cluster"

source ./params.sh
source ./sources.sh
source ./transformations.sh

# Generate
rm -rf "$GENERATED_DIR"

# for filename in "${SOURCE_FILES[@]}"; do
#   contents=$(cat "$SOURCES_BASEDIR"/"$filename")

#   for ((i = 0; i < ${#TRANSFORMATIONS[@]}; i++)); do
#     transform="${TRANSFORMATIONS[$i]}"
#     if [ -z "$contents" ]; then
#       continue
#     fi

#     cmd="$transform $filename"
#     contents=$(echo "$contents" | $cmd)
#   done

#   if [ -n "$contents" ]; then
#     mkdir -p "$(dirname "$GENERATED_DIR/$filename")"
#     echo "$contents" >"$GENERATED_DIR/$filename"
#   fi

# done

function run_transformations() {
  source ./params.sh
  source ./sources.sh
  source ./transformations.sh

  filename="$1"

  contents=$(cat "$SOURCES_BASEDIR"/"$filename")

  for ((i = 0; i < ${#TRANSFORMATIONS[@]}; i++)); do
    transform="${TRANSFORMATIONS[$i]}"
    if [ -z "$contents" ]; then
      continue
    fi

    cmd="$transform $filename"
    contents=$(echo "$contents" | $cmd)
  done

  if [ -n "$contents" ]; then
    mkdir -p "$(dirname "$GENERATED_DIR/$filename")"
    echo "$contents" >"$GENERATED_DIR/$filename"
  fi
}
export -f run_transformations

# Remove parallel citation log spam.
echo 'will cite' | parallel --citation &>/dev/null
parallel run_transformations {} ::: "${SOURCE_FILES[@]}"
