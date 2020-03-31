#!/bin/bash
#
# This file should contain `kubectl apply` commands for all of your configured resources.
# 
# This file should be run:
#   * When the cluster is first created
#   * Whenever the configuration for any resource has been updated

# Apply the base Soucegraph deployment
kubectl apply -l deploy=sourcegraph -k base/rbac-roles --prune
kubectl apply -l deploy=sourcegraph -k base --prune
