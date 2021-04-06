#!/usr/bin/env bash

set -euo pipefail

IMAGE="$1"
FILE="$2"

yq eval --exit-status ".spec.template.spec.containers.[] | select(.image == \"*/${IMAGE}*\")" "${FILE}"
