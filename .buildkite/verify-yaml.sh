#!/bin/bash

set -ex
cd "$(dirname "${BASH_SOURCE[0]}")/.."

gcloud container clusters get-credentials dogfood --zone us-central1-f --project sourcegraph-dogfood

kubectl apply --dry-run --validate --recursive -f base/ --context=gke_sourcegraph-dogfood_us-central1-f_dogfood
kubectl apply --dry-run --validate --recursive -f configure/ --context=gke_sourcegraph-dogfood_us-central1-f_dogfood

.buildkite/verify-label.sh
