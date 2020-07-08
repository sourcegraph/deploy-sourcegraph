#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"
set -euo pipefail

BMRecord="{=}"

for f in bundle-manager.*.yaml; do
  kind=$(yq read "$f" 'kind')
  dhallExpression=$(printf "let kubernetes = https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.17/package.dhall in kubernetes.%s.Type" "$kind")

  k8sDhall="$(yaml-to-dhall --file "$f" --records-loose "${dhallExpression}")"
  BMRecord="$BMRecord /\ { $kind = ${k8sDhall} }"
done

BMRecord="{ BundleManager = ${BMRecord} }"

WorkerRecord="{=}"

for f in worker.*.yaml; do
  kind=$(yq read "$f" 'kind')
  dhallExpression=$(printf "let kubernetes = https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.17/package.dhall in kubernetes.%s.Type" "$kind")

  k8sDhall="$(yaml-to-dhall --file "$f" --records-loose "${dhallExpression}")"
  WorkerRecord="$WorkerRecord /\ { $kind = ${k8sDhall} }"
done

WorkerRecord="{ Worker = ${WorkerRecord} }"

echo "${BMRecord} /\ ${WorkerRecord}" | dhall --explain --output upstream.dhall
