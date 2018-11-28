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

if ! [[ "${USER_EMAIL_ADDRESS}" ]]; then
  echo "Please set \$USER_EMAIL_ADDRESS before running this script." >&2
  exit 1
fi

BASE=$(dirname "${BASH_SOURCE[0]}")
SECRET_VAULT_PATH="secret/sync.v1/dev-workflow/production-sourcegraph/sourcegraph-eu1/gce-key-pair/cluster-keys"

function retrieveClusterSecret() {
  if ! GOOGLE_CREDENTIALS=$(imp-vault read-key --key="${SECRET_VAULT_PATH}") \
    || ! [[ "${GOOGLE_CREDENTIALS}" ]]; then
    echo "Failed to retrieve secret from Vault." >&2
    exit 1
  fi
}

function terraform-step() {
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
