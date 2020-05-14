#!/bin/bash

if [ ! "$(which src-alpha)" ]; then
  echo "Installing pre-release src to /usr/local/bin"
  mkdir -p /tmp/src-alpha
  cd /tmp/src-alpha
  wget https://github.com/sourcegraph/src-cli/releases/download/3.13.0-alpha/src-cli_3.13.0-SNAPSHOT-9f58a28_linux_amd64.tar.gz
  tar xvzf src-cli_3.13.0-SNAPSHOT-9f58a28_linux_amd64.tar.gz
  cp src /usr/local/bin/src-alpha
  chmod a+x /usr/local/bin/src-alpha
fi
