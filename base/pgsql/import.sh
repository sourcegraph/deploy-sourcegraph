#!/usr/bin/env bash

set -ex

cd "$(dirname "${BASH_SOURCE[0]}")"

mkdir -p dhall/{raw,human}

for f in *.yaml; do
  kind=$(yq read "$f" 'kind')
  dhallExpression=$(printf "let kubernetes = https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.17/package.dhall in kubernetes.%s.Type" "$kind")

  rawFile="raw/$(basename "$f" .yaml)-RAW-IMPORT.dhall"
  humanFile="human/$(basename "$f" .yaml).dhall"

  yaml-to-dhall "$dhallExpression" --file "$f" --output "$rawFile"
  yaml-to-dhall "$dhallExpression" --file "$f" --output "$humanFile"
  touch raw/package.dhall
  touch raw/human.dhall
done
