#!/usr/bin/env bash
#
# Run the integration test that deploys a Sourcegraph cluster with a restrictive security policy.
# Conveniently, this can be run from dev by setting the TEST_GCP_{ZONE,PROJECT,USERNAME} environment
# variables (assuming your local `gcloud` is auth'd with the GCP username). Optionally set NOCLEANUP
# to prevent cleaning up the cluster when finished.

set -xeuo

BUILD_CREATOR="${BUILD_CREATOR:-dev}"
BUILD_BRANCH="${BUILD_BRANCH:-dev}"
BUILD_UUID="${BUILD_UUID:-dev}"
[ ! -z "$TEST_GCP_ZONE" ]
[ ! -z "$TEST_GCP_PROJECT" ]

CLEANUP=""
trap 'bash -c "$CLEANUP"' EXIT

CLUSTER_NAME_SUFFIX=$(echo ${BUILD_UUID} | head -c 8)
CLUSTER_NAME="ds-test-restricted-${CLUSTER_NAME_SUFFIX}"
# get the STABLE channel version from GKE
CLUSTER_VERSION=$(gcloud container get-server-config --zone us-central1-a -q 2>&1 | grep "defaultClusterVersion" | awk '{ print $2}')

cd $(dirname "${BASH_SOURCE[0]}")

CURRENT_DIR=$(pwd)
DEPLOY_SOURCEGRAPH_ROOT=${CURRENT_DIR}/../../..

./install-src.sh

# set up the cluster

gcloud container clusters create ${CLUSTER_NAME} --cluster-version=${CLUSTER_VERSION} --zone ${TEST_GCP_ZONE} --num-nodes 3 --machine-type n1-standard-16 --disk-type pd-ssd --project ${TEST_GCP_PROJECT} --labels="cost-category=build,build-creator=${BUILD_CREATOR},build-branch=${BUILD_BRANCH},integration-test=restricted,repository=deploy-sourcegraph"

gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${TEST_GCP_ZONE} --project ${TEST_GCP_PROJECT}

# Configure if the test should clean up after itself - useful for debugging
if [ "${NOCLEANUP:-}" != "true" ]; then
  CLUSTER_CLEANUP="gcloud container clusters delete ${CLUSTER_NAME} --zone ${TEST_GCP_ZONE} --project ${TEST_GCP_PROJECT} --quiet"
  CLEANUP="$CLUSTER_CLEANUP; $CLEANUP"
fi

verify () {
  # hit it with one request

  kubectl -n $NAMESPACE port-forward svc/sourcegraph-frontend 30080 &
  CLEANUP="kill $!; $CLEANUP"
  sleep 2 # (initial delay in port-forward activating)
  curl --retry-connrefused --retry 2 --retry-delay 10 -m 30 http://localhost:30080

  /usr/local/bin/src version

  # run a validation script against it
  /usr/local/bin/src -endpoint http://localhost:30080 validate -context github_token=$GH_TOKEN validate.json
}

. restricted.sh
setup_restricted
deploy_restricted
verify
cleanup_restricted

. base.sh
setup_base
deploy_base
verify
cleanup_base
