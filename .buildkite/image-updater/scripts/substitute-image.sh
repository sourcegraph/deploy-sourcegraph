#!/usr/bin/env bash

set -euo pipefail

OLD_IMAGE="$1"
NEW_IMAGE="$2"
FILE="$3"

yq eval -i "(.spec.template.spec.containers.[]|select(.image == \"*/${OLD_IMAGE}*\").image)|=\"${NEW_IMAGE}\"" "${FILE}"
