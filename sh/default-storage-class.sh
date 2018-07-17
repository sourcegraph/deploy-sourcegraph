#!/bin/bash
# This configures a default storage class for each PersistentVolumeClaim.

set -e

cd "$(dirname "${BASH_SOURCE[0]}")/.."

if [ -z ${STORAGE_CLASS_NAME+x} ]; then
    read -p "Storage class name? " STORAGE_CLASS_NAME
fi

if [ -n "$STORAGE_CLASS_NAME" ]; then
    find base -type f -name "*PersistentVolumeClaim.yaml" -exec sh -c "cat {} | yj | jq '.spec.storageClassName = \"$STORAGE_CLASS_NAME\"' | jy > {}.new; mv {}.new {}" \;
else
    find base -type f -name "*PersistentVolumeClaim.yaml" -exec sh -c "cat {} | yj | jq 'del(.spec.storageClassName)' | jy > {}.new; mv {}.new {}" \;
fi

