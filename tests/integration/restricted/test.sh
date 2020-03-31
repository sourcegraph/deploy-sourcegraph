#!/usr/bin/env bash

set -ex

RANDOM_CLUSTER_NAME_SUFFIX=`cat /dev/urandom | tr -cd 'a-f0-9' | head -c 7`

CLUSTER_NAME="ds-test-restricted-${RANDOM_CLUSTER_NAME_SUFFIX}"

cd $(dirname "${BASH_SOURCE[0]}")

# set up the cluster, set up the fake user and restricted policy and then deploy the non-privileged overlay as that user

gcloud container clusters create ${CLUSTER_NAME} --zone ${TEST_GCP_ZONE} --num-nodes 3 --machine-type n1-standard-16 --disk-type pd-ssd --project ${TEST_GCP_PROJECT} --labels=cost-category=build

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

kubectl expose deployment sourcegraph-frontend --type=NodePort --name sourcegraph --type=LoadBalancer

# wait for it all to finish (we list out the ones with persistent volume claim because they take longer)

kubectl -n ns-sourcegraph rollout status -w statefulset/indexed-search
kubectl -n ns-sourcegraph rollout status -w deployment/lsif-server
kubectl -n ns-sourcegraph rollout status -w deployment/prometheus
kubectl -n ns-sourcegraph rollout status -w deployment/redis-cache
kubectl -n ns-sourcegraph rollout status -w deployment/redis-store
kubectl -n ns-sourcegraph rollout status -w statefulset/gitserver
kubectl -n ns-sourcegraph rollout status -w deployment/sourcegraph-frontend
kubectl -n ns-sourcegraph rollout status -w service/sourcegraph

# hit it with one request

SOURCEGRAPH_IP=`kubectl describe service sourcegraph | grep "LoadBalancer Ingress:" | cut -d ":" -f 2 | tr -d " "`

curl -m 10 https://${SOURCEGRAPH_IP}:3080

# delete cluster

gcloud container clusters delete ${CLUSTER_NAME} --zone ${TEST_GCP_ZONE} --project ${TEST_GCP_PROJECT} --quiet

