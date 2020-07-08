#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"
set -euo pipefail

CacheRecord="{=}"

for f in redis-cache.*.yaml; do
  kind=$(yq read "$f" 'kind')
  dhallExpression=$(printf "let kubernetes = https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.17/package.dhall in kubernetes.%s.Type" "$kind")

  k8sDhall="$(yaml-to-dhall --file "$f" --records-loose "${dhallExpression}")"
  CacheRecord="$CacheRecord /\ { $kind = ${k8sDhall} }"
done

CacheRecord="{ Cache = ${CacheRecord} }"

StoreRecord="{=}"

for f in redis-store.*.yaml; do
  kind=$(yq read "$f" 'kind')
  dhallExpression=$(printf "let kubernetes = https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.17/package.dhall in kubernetes.%s.Type" "$kind")

  k8sDhall="$(yaml-to-dhall --file "$f" --records-loose "${dhallExpression}")"
  StoreRecord="$StoreRecord /\ { $kind = ${k8sDhall} }"
done

StoreRecord="{ Store = ${StoreRecord} }"

echo "${CacheRecord} /\ ${StoreRecord}" | dhall --explain --output upstream.dhall
