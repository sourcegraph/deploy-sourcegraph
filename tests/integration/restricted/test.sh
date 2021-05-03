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

# set up the cluster, set up the fake user and restricted policy and then deploy the non-privileged overlay as that user

gcloud container clusters create ${CLUSTER_NAME} --cluster-version=${CLUSTER_VERSION} --zone ${TEST_GCP_ZONE} --num-nodes 3 --machine-type n1-standard-16 --disk-type pd-ssd --project ${TEST_GCP_PROJECT} --labels="cost-category=build,build-creator=${BUILD_CREATOR},build-branch=${BUILD_BRANCH},integration-test=restricted,repository=deploy-sourcegraph"

gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${TEST_GCP_ZONE} --project ${TEST_GCP_PROJECT}

# Configure if the test should clean up after itself - useful for debugging
if [ "${NOCLEANUP:-}" != "true" ]; then
  CLUSTER_CLEANUP="gcloud container clusters delete ${CLUSTER_NAME} --zone ${TEST_GCP_ZONE} --project ${TEST_GCP_PROJECT} --quiet"
  CLEANUP="$CLUSTER_CLEANUP; $CLEANUP"
fi

kubectl apply -f sourcegraph.StorageClass.yaml

kubectl apply -f nonroot-policy.yaml

kubectl create namespace ns-sourcegraph

kubectl create serviceaccount -n ns-sourcegraph fake-user

kubectl create rolebinding -n ns-sourcegraph fake-admin --clusterrole=admin --serviceaccount=ns-sourcegraph:fake-user

# Kubernetes < 1.16 change to '--resource=podsecuritypolicies.extensions'
kubectl create role -n ns-sourcegraph nonroot:unprivileged --verb=use --resource=podsecuritypolicies.extensions --resource-name=nonroot-policy

kubectl create rolebinding -n ns-sourcegraph fake-user:nonroot:unprivileged --role=nonroot:unprivileged --serviceaccount=ns-sourcegraph:fake-user

/bin/cat <<EOM >deploy_sourcegraph_git_ssh_config
Host *
    StrictHostKeyChecking no
EOM

kubectl create secret -n ns-sourcegraph generic gitserver-ssh --from-literal=rsa=supersecret --from-literal=config=topsecret

mkdir generated-cluster
CLEANUP="rm -rf generated-cluster; $CLEANUP"
"${DEPLOY_SOURCEGRAPH_ROOT}"/overlay-generate-cluster.sh non-privileged-create-cluster ${CURRENT_DIR}/generated-cluster

GS=${CURRENT_DIR}/generated-cluster/apps_v1_statefulset_gitserver.yaml
cat $GS | yj | jq '.spec.template.spec.containers[].volumeMounts += [{mountPath: "/home/sourcegraph/.ssh", name: "ssh"}]' | jy -o $GS
cat $GS | yj | jq '.spec.template.spec.volumes += [{name: "ssh", secret: {defaultMode: 384, secretName:"gitserver-ssh"}}]' | jy -o $GS

kubectl --as=system:serviceaccount:ns-sourcegraph:fake-user -n ns-sourcegraph apply -f ${CURRENT_DIR}/generated-cluster --recursive

# kubectl -n ns-sourcegraph expose deployment sourcegraph-frontend --type=NodePort --name sourcegraph --type=LoadBalancer --port=3080 --target-port=3080

# wait for it all to finish (we list out the ones with persistent volume claim because they take longer)

timeout 10m kubectl -n ns-sourcegraph rollout status -w statefulset/indexed-search
timeout 10m kubectl -n ns-sourcegraph rollout status -w deployment/prometheus
timeout 10m kubectl -n ns-sourcegraph rollout status -w deployment/redis-cache
timeout 10m kubectl -n ns-sourcegraph rollout status -w deployment/redis-store
timeout 10m kubectl -n ns-sourcegraph rollout status -w statefulset/gitserver
timeout 10m kubectl -n ns-sourcegraph rollout status -w deployment/sourcegraph-frontend

# hit it with one request

kubectl -n ns-sourcegraph port-forward svc/sourcegraph-frontend 30080 &
CLEANUP="kill $!; $CLEANUP"
sleep 2 # (initial delay in port-forward activating)
curl --retry-connrefused --retry 2 --retry-delay 10 -m 30 http://localhost:30080

/usr/local/bin/src version

# run a validation script against it
/usr/local/bin/src -endpoint http://localhost:30080 validate -context github_token=$GH_TOKEN validate.json
