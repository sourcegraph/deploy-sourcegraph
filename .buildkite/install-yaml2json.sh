#!/bin/bash

set -ex

# Version 1.3 panics on null inputs, see https://github.com/bronze1man/yaml2json/issues/15
VERSION=1.2

if [ ! $(which yaml2json) ]; then
    echo "Installing yaml2json to /usr/local/bin"
    wget https://github.com/bronze1man/yaml2json/releases/download/v${VERSION}/yaml2json_linux_amd64 -O /usr/local/bin/yaml2json
    chmod a+x /usr/local/bin/yaml2json
fi
