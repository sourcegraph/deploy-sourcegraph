#!/bin/bash

if [ ! $(which helm) ]; then
    echo "Installing helm to /usr/local/bin"
    rm -rf /tmp/helm
    mkdir -p /tmp/helm
    wget -O /tmp/helm/helm.tar.gz https://storage.googleapis.com/kubernetes-helm/helm-v2.9.1-linux-amd64.tar.gz
    tar -xvzf /tmp/helm/helm.tar.gz -C /tmp/helm
    mv /tmp/helm/linux-amd64/helm /usr/local/bin
fi
