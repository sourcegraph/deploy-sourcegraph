#!/bin/bash

VERSION=1.0.0

if [ ! $(which jy) ]; then
    echo "Installing jy to /usr/local/bin"
    wget https://github.com/sourcegraph/jy/releases/download/v${VERSION}/jy-${VERSION}-linux-amd64 -O /usr/local/bin/jy
    chmod a+x /usr/local/bin/jy
fi
