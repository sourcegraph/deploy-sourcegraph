#!/bin/bash
#
# This file should be filled in by customers with the `kubectl` commands that should be run on
# new cluster creation. 
#
# ./kubectl-apply-all.sh already runs all the `kubectl apply` commands 
# that applies your YAML files to the cluster. In addition, you should add commands 
# to create Kubernetes objects which satisfy one of the following conditions:
#
#   * The object is a secret that shouldn't be committed to version control. (.e.g `kubectl create secret ...`)
#   * The object will never be updated after creation. (e.g., a network load balancer - `kubectl expose ...`)
#
# Objects that do not meet the above criteria should NOT be created by this script. Instead, create
# a YAML file that can be `kubectl apply`d to the cluster, version that file in this repository, and add 
# the relevant `kubectl apply` command to ./kubectl-apply-all.sh

export GOOGLE_APPLICATION_CREDENTIALS="cluster_creds.json"
export USER_EMAIL_ADDRESS="seanrobertson@improbable.io"
pushd cluster/terraform

if [ ! -r ${GOOGLE_APPLICATION_CREDENTIALS} ]; then
  echo "You need the service account creds from LastPass."
  echo "Copy Shared-EngineeringEffectiveness > Sourcegraph-Cluster-SvcAcct to terraform/sourcegraph_cluster_creds.json"
  exit 1
fi

if ! terraform init; then
  echo "Unable to initialize Terraform.  Install it first."
  exit 1
fi

if ! terraform validate; then
  echo "Terraform validate failed.  Fix that before trying to apply it."
  exit 1
fi

if ! terraform apply; then
  echo "Terraform failed to apply.  Fix that before deploying workloads to the cluster."
  exit 1
fi

popd

# Set up cluster role binding so we can actually create things
kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user "${USER_EMAIL_ADDRESS}"

# Create namespace and set the default storage class to SSD
kubectl apply -f cluster/kube/

# And now apply the service configuration
./kubectl-apply-all.sh
