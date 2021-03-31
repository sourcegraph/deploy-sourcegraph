#!/usr/bin/env bash

cd "$(git rev-parse --show-toplevel)"
set -euo pipefail

IMAGE="$1"
FILE="$2"
TAG="$3"

function my_chronic() {
  tmp=$(mktemp) || return # this will be the temp file w/ the output
  "$@" >"$tmp" 2>&1       # this should run the command, respecting all arguments
  ret=$?
  [ "$ret" -eq 0 ] || cat "$tmp" # if $? (the return of the last run command) is not zero, cat the temp file
  rm -f "$tmp"
  return "$ret" # return the exit status of the command
}
export -f my_chronic

function file_contains_image() {
  local image="$1"
  local file="$2"

  yq eval --exit-status ".spec.template.spec.containers.[] | select(.image == \"*/${image}*\")" "${file}"
}
export -f file_contains_image

function get_new_image() {
  local image="$1"
  local tag="$2"

  srcimage -i "${image}:${tag}"
}
export -f get_new_image

function substitute_image() {
  local old_image="$1"
  local new_image="$2"
  local file="$3"

  yq eval -i "(.spec.template.spec.containers.[]|select(.image == \"*/${old_image}*\").image)|=\"${new_image}\"" "${file}"
}
export -f substitute_image

function run_srcimg() {
  local image="$1"
  local file="$2"
  local tag="$3"

  if file_contains_image "${image}" "${file}"; then
    new_image=$(get_new_image "${image}" "${tag}")
    substitute_image "${image}" "${new_image}" "${file}"
  fi

}
export -f run_srcimg

result=$(my_chronic run_srcimg "$IMAGE" "${FILE}" "${TAG}" 2>&1)
rc=$?

if [ -n "$result" ]; then
  echo "run-srcimg: ${IMAGE}@${TAG} on ${FILE}:"
  echo "$result"
  echo
fi

exit "$rc"
