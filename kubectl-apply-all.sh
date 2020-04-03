#!/bin/bash
#
# This file should contain `kubectl apply` commands for all of your configured resources.
# 
# This file should be run:
#   * When the cluster is first created
#   * Whenever the configuration for any resource has been updated

# Apply the base Soucegraph deployment

FILES=`find base -name "*.yaml" \( ! -name kustomization.yaml \)  | tr "\n" "," | sed 's/,$/ /' | tr " " "\n"`

kubectl apply --prune -l deploy=sourcegraph -f ${FILES} --recursive
