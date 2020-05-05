#!/usr/bin/env bash

set -ex

cd "$(dirname "${BASH_SOURCE[0]}")"

suffix="RAW-IMPORT.dhall"

rm ./*"-$suffix" || true

for f in *.yaml; do
  kind=$(yq read "$f" 'kind')
  dhallExpression=$(printf "let kubernetes = https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.17/package.dhall in kubernetes.%s.Type" "$kind")
  yaml-to-dhall "$dhallExpression" --file "$f" --output "$(basename "$f" .yaml)-$suffix"
done
