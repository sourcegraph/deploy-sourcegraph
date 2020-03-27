#!/bin/bash

set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

# set up the cluster, set up the fake user and restricted policy and then deploy the non-privileged overlay as that user

gcloud beta container clusters create uwe-test-restricted-3 --zone us-central1-c --release-channel regular --num-nodes 3 --machine-type n1-standard-16 --disk-type pd-ssd --project sourcegraph-server

gcloud container clusters get-credentials uwe-test-restricted-3 --zone us-central1-c --project sourcegraph-server

kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user $(gcloud config get-value account)

kubectl apply -f sourcegraph.StorageClass.yaml

kubectl apply -f nonroot-policy.yaml

kubectl create namespace ns-sourcegraph

kubectl create serviceaccount -n ns-sourcegraph fake-user

kubectl create rolebinding -n ns-sourcegraph fake-admin --clusterrole=admin --serviceaccount=ns-sourcegraph:fake-user

kubectl create role -n ns-sourcegraph nonroot:unprivileged --verb=use --resource=podsecuritypolicy --resource-name=nonroot-policy

kubectl create rolebinding -n ns-sourcegraph fake-user:nonroot:unprivileged --role=nonroot:unprivileged --serviceaccount=ns-sourcegraph:fake-user

kubectl --as=system:serviceaccount:ns-sourcegraph:fake-user -n ns-sourcegraph apply -k ../../../overlays/non-privileged

# wait for it all to finish (we list out the ones with persistent volume claim because they take longer)

kubectl -n ns-sourcegraph rollout status -w deployment/indexed-search
kubectl -n ns-sourcegraph rollout status -w deployment/lsif-server
kubectl -n ns-sourcegraph rollout status -w deployment/prometheus
kubectl -n ns-sourcegraph rollout status -w deployment/redis-cache
kubectl -n ns-sourcegraph rollout status -w deployment/redis-store
kubectl -n ns-sourcegraph rollout status -w deployment/gitserver
kubectl -n ns-sourcegraph rollout status -w deployment/sourcegraph-frontend

