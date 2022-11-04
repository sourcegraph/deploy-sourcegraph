#!/bin/bash

set -ex
cd "$(dirname "${BASH_SOURCE[0]}")/.."

gcloud container clusters get-credentials cloud --zone us-central1-f --project sourcegraph-dev

kubectl apply --dry-run --validate --recursive -k base/ --context=gke_sourcegraph-dev_us-central1-f_cloud
kubectl apply --dry-run --validate --recursive -k configure/ --context=gke_sourcegraph-dev_us-central1-f_cloud

.buildkite/verify-label.sh
