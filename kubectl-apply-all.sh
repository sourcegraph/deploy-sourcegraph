#!/bin/bash
#
# This file should contain `kubectl apply` commands for all of your configured resources.
# 
# This file should be run:
#   * When the cluster is first created
#   * Whenever the configuration for any resource has been updated

# Apply the base Soucegraph deployment
kubectl apply -k base -l deploy=sourcegraph
kubectl apply -k base/rbac-roles -l deploy=sourcegraph
