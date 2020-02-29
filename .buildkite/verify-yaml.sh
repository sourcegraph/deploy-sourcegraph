#!/bin/bash

set -ex
cd "$(dirname "${BASH_SOURCE[0]}")/.."

gcloud container clusters get-credentials dogfood --zone us-central1-a --project sourcegraph-dev

kubectl version

kubectl apply --dry-run --validate -k base --context=gke_sourcegraph-dev_us-central1-a_dogfood
kubectl apply --dry-run --validate --recursive -f configure/ --context=gke_sourcegraph-dev_us-central1-a_dogfood

.buildkite/verify-label.sh
