#!/bin/bash

set -ex
cd "$(dirname "${BASH_SOURCE[0]}")/.."

gcloud container clusters get-credentials cloud --zone us-central1-f --project sourcegraph-dev

kustomize build ./base/. | kubectl apply --dry-run --validate -f --context=gke_sourcegraph-dev_us-central1-f_cloud -
kustomize build ./configure/. | kubectl apply --prune -l deploy=sourcegraph -f --dry-run --validate --context=gke_sourcegraph-dev_us-central1-f_cloud -

.buildkite/verify-label.sh
