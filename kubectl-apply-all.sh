#!/bin/bash
#
# This file should contain `kubectl apply` commands for all of your configured resources.
#
# This file should be run:
#   * When the cluster is first created
#   * Whenever the configuration for any resource has been updated

# Apply the base Soucegraph deployment

# Applies k8s resource files from first argument (a directory) using label specified as second argument.
# Traverses first argument recursively collecting yaml files but avoiding kustomization.yaml files.
apply() {
  local DIR=$1
  local LABEL=$2

  local FILES=$(find ${DIR} -name "*.yaml" \( ! -name kustomization.yaml \) | tr "\n" "," | sed 's/,$/ /' | tr " " "\n")

  kubectl apply --prune -l ${LABEL} -f ${FILES}
}

apply base deploy=sourcegraph
