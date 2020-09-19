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

### BEGIN CUSTOMIZATIONS

# shellcheck disable=SC2068

# dogfood-k8s namespaces
kubectl apply --prune -l deploy=namespace -f namespaces --recursive $@

# dogfood-k8s ingress
./configure/ingress-nginx/install.sh

# *.sgdev.org certificate, find in 1password and save to the defined files
kubectl create secret tls sourcegraph-tls --key ./sgdev-tls-key --cert ./sgdev-tls-cert $@

### END CUSTOMIZATIONS

./kubectl-apply-all.sh $@
