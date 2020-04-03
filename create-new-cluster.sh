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

kubectl apply -l deploy=sourcegraph -k overlays/non-root-create-cluster
