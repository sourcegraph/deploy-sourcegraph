#!/usr/bin/env bash

set -ex

cd "$(dirname "${BASH_SOURCE[0]}")"

for f in ./dhall/human/*.dhall; do
  if [ "$(basename "$f")" == "package.dhall" ]; then
    continue
  fi

  yamlFile="$PWD/$(basename "$f" .dhall)".yaml

  dhall-to-yaml --file "$f" --output "$yamlFile"
  yarn prettier "$yamlFile"
done
