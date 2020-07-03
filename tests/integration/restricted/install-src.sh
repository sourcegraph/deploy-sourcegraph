#!/bin/bash

if [ ! "$(which src-alpha)" ]; then
  echo "Installing pre-release src to /usr/local/bin"
  mkdir -p /tmp/src-alpha
  cd /tmp/src-alpha
  wget https://github.com/sourcegraph/src-cli/releases/download/3.18.0-alpha/src-cli_3.18.0-alpha-SNAPSHOT-3b23f74_linux_amd64.tar.gz
  tar xvzf src-cli_3.13.0-SNAPSHOT-9f58a28_linux_amd64.tar.gz
  cp src /usr/local/bin/src-alpha
  chmod a+x /usr/local/bin/src-alpha
fi

if [ ! "$(which jy)" ]; then
  echo "Installing jy to /usr/local/bin"
  mkdir -p /tmp/jy
  cd /tmp/jy
  wget https://github.com/sourcegraph/jy/releases/download/v1.0.0/jy-1.0.0-linux-amd64
  cp jy-1.0.0-linux-amd64 /usr/local/bin/jy
  chmod a+x /usr/local/bin/jy
fi

if [ ! "$(which yj)" ]; then
  echo "Installing yj to /usr/local/bin"
  mkdir -p /tmp/yj
  cd /tmp/yj
  wget https://github.com/sourcegraph/yj/releases/download/v1.0.0/yj-1.0.0-linux-amd64
  cp yj-1.0.0-linux-amd64 /usr/local/bin/yj
  chmod a+x /usr/local/bin/yj
fi
