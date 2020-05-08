#!/usr/bin/env bash

SOURCES_BASEDIR=".."
SOURCE_FILES=()

for f in "${INPUT_SOURCE_FILES[@]}"; do
  SOURCE_FILES+=("${f#$SOURCES_BASEDIR/}")
done

for SOURCE_DIR in "${INPUT_SOURCE_DIRS[@]}"; do
  for f in $(find "$SOURCES_BASEDIR/$SOURCE_DIR" -name "*.yaml" | grep -v kustomization.yaml); do
    SOURCE_FILES+=("${f#$SOURCES_BASEDIR/}")
  done
done
