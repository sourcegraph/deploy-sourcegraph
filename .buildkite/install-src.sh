#!/bin/bash

echo "Installing pre-release src to /usr/local/bin"
wget https://github.com/sourcegraph/src-cli/releases/download/3.13.0-alpha/src-cli_3.13.0-SNAPSHOT-9f58a28_linux_amd64.tar.gz /tmp
cd /tmp
tar xvzf src-cli_3.13.0-SNAPSHOT-9f58a28_linux_amd64.tar.gz
cp src-cli_3.13.0-SNAPSHOT-9f58a28_linux_amd64/src /usr/local/bin/src-alpha
chmod a+x /usr/local/bin/src-alpha

