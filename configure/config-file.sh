#!/bin/bash
# Updates the name of the config-file ConfigMap to include a content hash.
# This forces services that depend on the config-file ConfigMap to restart when the data changes.

set -e

cd "$(dirname "${BASH_SOURCE[0]}")/.."

BASE=${BASE:-base}

CONFIG_FILE_HASH=$(cat $BASE/config-file.ConfigMap.yaml | yj | jq --raw-output .data | md5sum | cut -c1-10)

find $BASE -name "*yaml" -exec sed -i.sedibak -e "s/name: config-file.*/name: config-file-$CONFIG_FILE_HASH/g" {} +
find $BASE -name "*.sedibak" -delete
