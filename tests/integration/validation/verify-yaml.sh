#!/bin/bash

set -ex
cd "$(dirname "${BASH_SOURCE[0]}")"

./install-kubeconform.sh

CURRENT_DIR=$(pwd)
DEPLOY_SOURCEGRAPH_ROOT=${CURRENT_DIR}/../../..

cd $DEPLOY_SOURCEGRAPH_ROOT

for version in 1.16.0 1.17.0 1.18.0 1.19.0 1.20.0 1.21.0 1.22.0
do
    kcommand="kubeconform -kubernetes-version $version"
    find base -name '*.yaml' -exec $kcommand {} +
    find configure -name '*.yaml' -exec $kcommand {} +
done
