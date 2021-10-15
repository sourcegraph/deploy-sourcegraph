#!/bin/bash

set -e
cd "$(dirname "${BASH_SOURCE[0]}")/.."

VERSION=v0.4.12

if [ ! "$(which kubeconform)" ]; then
  echo "Installing kubeconform to /usr/local/bin"
  curl -fL -O "https://github.com/yannh/kubeconform/releases/download/${VERSION}/kubeconform-linux-amd64.tar.gz"
  tar xf kubeconform-linux-amd64.tar.gz
  mv kubeconform /usr/local/bin
  rm kubeconform-linux-amd64.tar.gz
fi
