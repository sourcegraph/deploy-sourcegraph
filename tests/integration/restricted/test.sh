#!/usr/bin/env bash

set -ex

RANDOM_CLUSTER_NAME_SUFFIX=`cat /dev/urandom | tr -cd 'a-f0-9' | head -c 7`

CLUSTER_NAME="ds-test-restricted-${RANDOM_CLUSTER_NAME_SUFFIX}"

cd $(dirname "${BASH_SOURCE[0]}")

# set up the cluster, set up the fake user and restricted policy and then deploy the non-privileged overlay as that user

gcloud container clusters create ${CLUSTER_NAME} --zone ${TEST_GCP_ZONE} --num-nodes 3 --machine-type n1-standard-16 --disk-type pd-ssd --project ${TEST_GCP_PROJECT}

gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${TEST_GCP_ZONE} --project ${TEST_GCP_PROJECT}

kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user ${TEST_GCP_USERNAME}

kubectl apply -f sourcegraph.StorageClass.yaml

kubectl apply -f nonroot-policy.yaml

kubectl create namespace ns-sourcegraph

kubectl create serviceaccount -n ns-sourcegraph fake-user

kubectl create rolebinding -n ns-sourcegraph fake-admin --clusterrole=admin --serviceaccount=ns-sourcegraph:fake-user

kubectl create role -n ns-sourcegraph nonroot:unprivileged --verb=use --resource=podsecuritypolicy --resource-name=nonroot-policy

kubectl create rolebinding -n ns-sourcegraph fake-user:nonroot:unprivileged --role=nonroot:unprivileged --serviceaccount=ns-sourcegraph:fake-user

kubectl --as=system:serviceaccount:ns-sourcegraph:fake-user -n ns-sourcegraph apply -k ${DEPLOY_SOURCEGRAPH_ROOT}/overlays/non-privileged

# wait for it all to finish (we list out the ones with persistent volume claim because they take longer)

kubectl -n ns-sourcegraph rollout status -w statefulset/indexed-search
kubectl -n ns-sourcegraph rollout status -w deployment/lsif-server
kubectl -n ns-sourcegraph rollout status -w deployment/prometheus
kubectl -n ns-sourcegraph rollout status -w deployment/redis-cache
kubectl -n ns-sourcegraph rollout status -w deployment/redis-store
kubectl -n ns-sourcegraph rollout status -w statefulset/gitserver
kubectl -n ns-sourcegraph rollout status -w deployment/sourcegraph-frontend

# TODO(uwedeportivo): hit it with a request (we need ingress or nodeport)

# delete cluster

gcloud container clusters delete ${CLUSTER_NAME} --quiet

