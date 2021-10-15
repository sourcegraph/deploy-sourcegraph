#!/bin/bash

set -ex
cd "$(dirname "${BASH_SOURCE[0]}")"

./install-kubeval.sh

CURRENT_DIR=$(pwd)
DEPLOY_SOURCEGRAPH_ROOT=${CURRENT_DIR}/../../..

cd $DEPLOY_SOURCEGRAPH_ROOT

# Unofficial fork from kubeconform since default repo isn't maintained - yikes?
kcommand="kubeval --strict -s https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master"
for version in 1.15.0 1.16.0 1.17.0 1.18.0 1.19.0 1.20.0 1.21.0 1.22.0
do
    find base -name '*.yaml' -exec $kcommand -v $version {} +
    find configure -name '*.yaml' -exec $kcommand -v $version {} +
done
