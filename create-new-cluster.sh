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

export USER_EMAIL_ADDRESS="seanrobertson@improbable.io"

retrieveClusterSecret() {
  # Make sure that we don't leave secrets around on disk in any case.
  temp_dir=$(mktemp -d)
  key_path="${temp_dir}/cluster_keys.json"
  function cleanup_secrets() {
    rm -rf "${temp_dir}"
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

retrieveClusterSecret

pushd cluster/terraform

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

# Destroy any leftover secrets, just in case
cleanup_secrets
