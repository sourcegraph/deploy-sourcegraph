#!/bin/bash
# This configures a default storage class for each PersistentVolumeClaim.

set -e

cd "$(dirname "${BASH_SOURCE[0]}")/.."

BASE=${BASE:-base}

if [ -z ${STORAGE_CLASS_NAME+x} ]; then
    read -p "Storage class name [none]: " STORAGE_CLASS_NAME
fi

if [ -n "$STORAGE_CLASS_NAME" ]; then
    find $BASE -name "*PersistentVolumeClaim.yaml" -exec sh -c "cat {} | yj | jq '.spec.storageClassName = \"$STORAGE_CLASS_NAME\"' | jy -o {}" \;
    echo "> Using configured storage class: $STORAGE_CLASS_NAME"
else
    find $BASE -name "*PersistentVolumeClaim.yaml" -exec sh -c "cat {} | yj | jq 'del(.spec.storageClassName)' | jy -o {}" \;
    echo "> Using default storage class"
fi
