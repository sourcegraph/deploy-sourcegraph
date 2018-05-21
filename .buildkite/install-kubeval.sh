#!/bin/bash

VERSION=0.7.1

if [ ! $(which kubeval) ]; then
    echo "Installing kubeval to /usr/local/bin"
    wget https://github.com/garethr/kubeval/releases/download/${VERSION}/kubeval-linux-amd64.tar.gz
    tar xf kubeval-linux-amd64.tar.gz
    mv kubeval /usr/local/bin
    rm kubeval-linux-amd64.tar.gz
fi
