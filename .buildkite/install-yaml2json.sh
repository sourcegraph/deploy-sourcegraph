#!/bin/bash

set -ex

VERSION=1.2

if [ ! $(which yaml2json) ]; then
    echo "Installing yaml2json to /usr/local/bin"
    wget https://github.com/bronze1man/yaml2json/releases/download/v${VERSION}/yaml2json_linux_amd64 -O /usr/local/bin/yaml2json
    chmod a+x /usr/local/bin/yaml2json
fi
