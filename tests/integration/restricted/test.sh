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
[ ! -z "$TEST_GCP_USERNAME" ]

CLEANUP=""
trap 'bash -c "$CLEANUP"' EXIT

CLUSTER_NAME_SUFFIX=$(echo ${BUILD_UUID} | head -c 8)

CLUSTER_NAME="ds-test-restricted-${CLUSTER_NAME_SUFFIX}"

cd $(dirname "${BASH_SOURCE[0]}")

# set up the cluster, set up the fake user and restricted policy and then deploy the non-privileged overlay as that user

gcloud container clusters create ${CLUSTER_NAME} --zone ${TEST_GCP_ZONE} --num-nodes 3 --machine-type n1-standard-16 --disk-type pd-ssd --project ${TEST_GCP_PROJECT} --labels="cost-category=build,build-creator=${BUILD_CREATOR},build-branch=${BUILD_BRANCH},integration-test=fresh"

gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${TEST_GCP_ZONE} --project ${TEST_GCP_PROJECT}
if [ -z "${NOCLEANUP:-}" ]; then
  CLUSTER_CLEANUP="gcloud container clusters delete ${CLUSTER_NAME} --zone ${TEST_GCP_ZONE} --project ${TEST_GCP_PROJECT} --quiet"
  CLEANUP="$CLUSTER_CLEANUP; $CLEANUP"
fi

kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user ${TEST_GCP_USERNAME}

kubectl apply -f sourcegraph.StorageClass.yaml

kubectl apply -f nonroot-policy.yaml

kubectl create namespace ns-sourcegraph

kubectl create serviceaccount -n ns-sourcegraph fake-user

kubectl create rolebinding -n ns-sourcegraph fake-admin --clusterrole=admin --serviceaccount=ns-sourcegraph:fake-user

kubectl create role -n ns-sourcegraph nonroot:unprivileged --verb=use --resource=podsecuritypolicy --resource-name=nonroot-policy

kubectl create rolebinding -n ns-sourcegraph fake-user:nonroot:unprivileged --role=nonroot:unprivileged --serviceaccount=ns-sourcegraph:fake-user

mkdir generated-cluster
CLEANUP="rm -rf generated-cluster; $CLEANUP"
"${DEPLOY_SOURCEGRAPH_ROOT}"/overlay-generate-cluster.sh non-privileged-create-cluster generated-cluster

kubectl --as=system:serviceaccount:ns-sourcegraph:fake-user -n ns-sourcegraph apply -f generated-cluster --recursive

# kubectl -n ns-sourcegraph expose deployment sourcegraph-frontend --type=NodePort --name sourcegraph --type=LoadBalancer --port=3080 --target-port=3080

# wait for it all to finish (we list out the ones with persistent volume claim because they take longer)

timeout 5m kubectl -n ns-sourcegraph rollout status -w statefulset/indexed-search
timeout 5m kubectl -n ns-sourcegraph rollout status -w deployment/precise-code-intel-bundle-manager
timeout 5m kubectl -n ns-sourcegraph rollout status -w deployment/prometheus
timeout 5m kubectl -n ns-sourcegraph rollout status -w deployment/redis-cache
timeout 5m kubectl -n ns-sourcegraph rollout status -w deployment/redis-store
timeout 5m kubectl -n ns-sourcegraph rollout status -w statefulset/gitserver
timeout 5m kubectl -n ns-sourcegraph rollout status -w deployment/sourcegraph-frontend

# hit it with one request

kubectl -n ns-sourcegraph port-forward svc/sourcegraph-frontend 30080 &
CLEANUP="kill $!; $CLEANUP"
sleep 2 # (initial delay in port-forward activating)
curl --retry-connrefused --retry 2 --retry-delay 10 -m 30 http://localhost:30080
