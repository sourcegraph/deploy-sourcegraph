#!/bin/bash

set -e
cd "$(dirname "${BASH_SOURCE[0]}")/.."

VERSION=v0.16.1

if [ ! "$(which kubeval)" ]; then
  echo "Installing kubeval to /usr/local/bin"
  curl -fL -O "https://github.com/instrumenta/kubeval/releases/download/${VERSION}/kubeval-linux-amd64.tar.gz"
  tar xf kubeval-linux-amd64.tar.gz
  mv kubeval /usr/local/bin
  rm kubeval-linux-amd64.tar.gz
fi
