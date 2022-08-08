#!/bin/bash

set -ex
cd "$(dirname "${BASH_SOURCE[0]}")/.."

gcloud container clusters get-credentials cloud --zone us-central1-f --project sourcegraph-dev

kubectl apply --dry-run --validate --recursive -f base/ --context=gke_sourcegraph-dev_us-central1-f_cloud
kubectl apply --dry-run --validate --recursive -f configure/ --context=gke_sourcegraph-dev_us-central1-f_cloud

.buildkite/verify-label.sh
