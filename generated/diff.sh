#!/usr/bin/env bash

set -eu
cd "$(dirname "${BASH_SOURCE[0]}")"/..

export TEMP_ORIGINAL_FOLDER=".diff/ORIGINAL"
export TEMP_GENERATED_FOLDER=".diff/GENERATED"

cleanup() {
  rm -rf .diff
}
trap cleanup EXIT

mkdir -p "$TEMP_ORIGINAL_FOLDER"
mkdir -p "$TEMP_GENERATED_FOLDER"

makeNormalizedFile() {
  local originalFile=$1
  local root=$2
  local dest=$3

  destFile="$dest${originalFile#"$root"}"
  mkdir -p "$(dirname "$destFile")"
  yq read --tojson "$originalFile" | jq -S -f ./generated/sort_env_vars.jq | yq read --prettyPrint --stripComments - >"$destFile"
}
export -f makeNormalizedFile

makeNormalizedCopy() {
  local root=$1
  local dest=$2

  mapfile -t originalFiles < <(find "$root" -name "*.yaml")

  parallel makeNormalizedFile {} "$root" "$dest" ::: "${originalFiles[@]}"
}
export -f makeNormalizedCopy

formatBase() {
  makeNormalizedCopy "${ORIGINAL_BASE:-"base"}" "$TEMP_ORIGINAL_FOLDER"
}
export -f formatBase

formatGenerated() {
  makeNormalizedCopy "${GENERATED_BASE:-"generated/generated-cluster/base"}" "$TEMP_GENERATED_FOLDER"
}
export -f formatGenerated

# Remove parallel citation log spam.
echo 'will cite' | parallel --citation &>/dev/null
parallel {} ::: formatBase formatGenerated

git diff --no-index "$TEMP_ORIGINAL_FOLDER" "$TEMP_GENERATED_FOLDER"
