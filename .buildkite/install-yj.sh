#!/bin/bash

VERSION=1.0.0

which pulumi 
ls /root/.asdf/shims

if [ ! $(which yj) ]; then
    echo "Installing yj to /usr/local/bin"
    wget https://github.com/sourcegraph/yj/releases/download/v${VERSION}/yj-${VERSION}-linux-amd64 -O /usr/local/bin/yj
    chmod a+x /usr/local/bin/yj
fi
