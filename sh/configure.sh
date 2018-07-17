#!/bin/bash
# Updates the name of the config-file ConfigMap to include a content hash.
# This forces services that depend on the config-file ConfigMap to restart when the data changes.

cd "$(dirname "${BASH_SOURCE[0]}")/.."

set -e

CONFIG_FILE_HASH=$(cat base/config-file.ConfigMap.yaml | yj | jq --raw-output .data | md5 | cut -c1-10)

find base -type f -name "*yaml" -exec sed -i.sedibak -e "s/name: config-file.*/name: config-file-$CONFIG_FILE_HASH/g" {} +
find base -type f -name "*.sedibak" -delete
