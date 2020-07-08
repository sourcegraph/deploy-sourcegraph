#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"
set -euo pipefail

record="{=}"

for f in *.yaml; do
  kind=$(yq read "$f" 'kind')
  dhallExpression=$(printf "let kubernetes = https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.17/package.dhall in kubernetes.%s.Type" "$kind")

  k8sDhall="$(yaml-to-dhall --file "$f" --records-loose "${dhallExpression}")"
  record="$record /\ { $kind = ${k8sDhall} }"
done

dhallExpression=$(printf "let kubernetes = https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.17/package.dhall in kubernetes.%s.Type" "Service")

k8sDhall="$(yaml-to-dhall --file "jaeger-query.Service.yaml.bk" --records-loose "${dhallExpression}")"
record="$record /\ { Query = ${k8sDhall} }"

dhallExpression=$(printf "let kubernetes = https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/1.17/package.dhall in kubernetes.%s.Type" "Service")

k8sDhall="$(yaml-to-dhall --file "jaeger-collector.Service.yaml.bk" --records-loose "${dhallExpression}")"
record="$record /\ { Collector = ${k8sDhall} }"

echo "$record" | dhall --explain --output upstream.dhall
