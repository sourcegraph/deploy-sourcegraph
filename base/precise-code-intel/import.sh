#!/usr/bin/env bash

set -ex

cd "$(dirname "${BASH_SOURCE[0]}")"

mkdir -p dhall/{raw,human}

for f in *.yaml; do
  kind=$(yq read "$f" 'kind')
  dhallExpression=$(printf "let kubernetes = https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.17/package.dhall in kubernetes.%s.Type" "$kind")

  parsedFile="$(basename "$f" .yaml)-RAW-IMPORT.dhall"

  yaml-to-dhall "$dhallExpression" --file "$f" --output "$parsedFile"
  cp "$parsedFile" "dhall/raw/$(basename "$f" .yaml)-RAW-IMPORT.dhall"
  cp "$parsedFile" "dhall/human/$(basename "$f" .yaml).dhall"
  rm "$parsedFile"

done

touch dhall/human/package.dhall
touch dhall/raw/package.dhall
