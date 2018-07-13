#!/bin/bash

VERSION=1.0.3

if [ ! $(which kustomize) ]; then
    echo "Installing kustomize to /usr/local/bin"
    wget https://github.com/kubernetes-sigs/kustomize/releases/download/v${VERSION}/kustomize_${VERSION}_linux_amd64 -O /usr/local/bin/kustomize
    chmod a+x /usr/local/bin/kustomize
fi
