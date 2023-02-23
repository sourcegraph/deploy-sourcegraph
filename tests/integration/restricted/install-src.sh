#!/bin/bash

target_src_version="4.5.0"
current_src_version=$(src version | grep -i current | sed 's/current version: //i')

if [ "$current_src_version" != "$target_src_version" ]; then
  echo "Installing src v${target_src_version} to /usr/local/bin"
  mkdir -p /tmp/src
  cd /tmp/src
  wget "https://github.com/sourcegraph/src-cli/releases/download/${target_src_version}/src-cli_${target_src_version}_linux_amd64.tar.gz"
  tar xvzf "src-cli_${target_src_version}_linux_amd64.tar.gz"
  cp src /usr/local/bin/src
  chmod a+x /usr/local/bin/src
else
  echo "Found src v${target_src_version} already installed."
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
