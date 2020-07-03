#!/bin/bash
#
# This file should contain `kubectl apply` commands for all of your configured resources.
#
# This file should be run:
#   * When the cluster is first created
#   * Whenever the configuration for any resource has been updated
#
# The --prune flag is destructive and should always be used 
# in conjunction with -f base and -l deploy=sourcegraph. Otherwise, it will delete all resources 
# previously created by create or apply that are not specified in the command.
#
# Apply the base Soucegraph deployment
kubectl apply --prune -l deploy=sourcegraph -f base --recursive $@
