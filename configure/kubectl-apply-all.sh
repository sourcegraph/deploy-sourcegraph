#!/bin/bash
#
# This file should be filled in with simple `kubectl apply` commands 
# that will apply the YAML configuration files for each resource that 
# are deployed / you want to be deployed to your cluster. 
# 
# This file should be run:
#   * When the cluster is first created
#   * Whenever the configuration for any resource has been updated


kubectl apply --prune -l deploy=sourcegraph -f base --recursive