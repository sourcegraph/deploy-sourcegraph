#!/bin/bash

if [ ! "$(which src)" ]; then
  echo "Installing src to /usr/local/bin"
  mkdir -p /tmp/src
  cd /tmp/src
  wget https://github.com/sourcegraph/src-cli/releases/download/3.21.7/src-cli_3.21.7_linux_amd64.tar.gz
  tar xvzf src-cli_3.21.7_linux_amd64.tar.gz
  cp src /usr/local/bin/src
  chmod a+x /usr/local/bin/src
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
