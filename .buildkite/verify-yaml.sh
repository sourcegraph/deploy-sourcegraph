#!/bin/bash

set -ex
cd "$(dirname "${BASH_SOURCE[0]}")/.."

.buildkite/install-kubeval.sh

gcloud container clusters get-credentials dogfood-cluster-7 --zone us-central1-a --project sourcegraph-dev

kubectl apply --dry-run --validate --recursive -f base/
kubectl apply --dry-run --validate --recursive -f configure/

find base -name '*.yaml' -exec kubeval {} +
find configure -name '*.yaml' -exec kubeval {} +

.buildkite/verify-label.sh
