#!/bin/bash
# Updates the content of config-file.ConfigMap.yaml and appends a content hash to the name.
# This forces services that depend on the config-file ConfigMap to restart when the data changes.

set -e

cd "$(dirname "${BASH_SOURCE[0]}")/.."

BASE=${BASE:-base}

if [ -z ${SITE_CONFIG_PATH+x} ]; then
    read -p "Path to site config.json [none]: " SITE_CONFIG_PATH
fi

CM=$BASE/config-file.ConfigMap.yaml

if [ -n "$SITE_CONFIG_PATH" ]; then
    SITE_CONFIG=$(cat $SITE_CONFIG_PATH | ./configure/util/sanitize.sh)
    # Concat the environment variable instead of embedding since the file contents
    # might contain charaters that could be interpreted by the shell (e.g. $).
    JQARG=".data.\"config.json\" = \"""$SITE_CONFIG""\""
    cat $CM | yj | jq "$JQARG" | jy -o $CM
fi

CONFIG_FILE_HASH=$(cat $CM | yj | jq --raw-output .data | md5sum | cut -c1-10)

find $BASE -name "*yaml" -exec sed -i.sedibak -e "s/name: config-file.*/name: config-file-$CONFIG_FILE_HASH/g" {} +
find $BASE -name "*.sedibak" -delete
