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

BASE=$(dirname "${BASH_SOURCE[0]}")

export USER_EMAIL_ADDRESS="seanrobertson@improbable.io"

function retrieveClusterSecret() {
  # Make sure that we don't leave secrets around on disk in any case.
  key_path=$(mktemp)
  function cleanup_secrets() {
    rm -rf "${key_path}"
  }
  trap cleanup_secrets EXIT

  # Retrieve the secret from Vault
  imp-vault read-key \
    --key="secret/sync.v1/dev-workflow/production-sourcegraph/sourcegraph-eu1/gce-key-pair/cluster-keys" \
    --write_to="${key_path}"

  if [ $? -ne 0 ]; then
    echo "Failed to retrieve secret from Vault.  Do you have permission?"
    exit 1
  fi
  
  export GOOGLE_APPLICATION_CREDENTIALS="${key_path}"
}

function terraform-step {
  if ! terraform "$@"; then
    echo "Terraform $1 failed" >&2
    exit 1
  fi
}

retrieveClusterSecret

pushd "${BASE}/cluster/terraform" || exit 1
terraform-step init
terraform-step validate
terraform-step apply

popd

# Set up cluster role binding so we can actually create things
kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user "${USER_EMAIL_ADDRESS}"

# Create namespace and set the default storage class to SSD
kubectl apply -f cluster/kube/

# And now apply the service configuration
./kubectl-apply-all.sh
