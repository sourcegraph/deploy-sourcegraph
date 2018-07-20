#!/bin/bash

set -ex
cd "$(dirname "${BASH_SOURCE[0]}")/.."

.buildkite/install-jy.sh
.buildkite/install-yj.sh
.buildkite/install-kubeval.sh

# Setup
rm -rf generated
mkdir -p generated
cp -r base/* generated/

# Test all configuration scripts disabled.
BASE=generated \
JAEGER_ENABLED=n \
LANGUAGE_SERVERS= \
EXPERIMENTAL_LANGUAGE_SERVERS= \
PROMETHEUS_ENABLED=n \
SSD_NODE_PATH= \
FRONTEND_TLS_CERTIFICATE_PATH= \
FRONTEND_TLS_PRIVATE_KEY_PATH= \
GITSERVER_REPLICA_COUNT= \
GITSERVER_SSH_PRIVATE_KEY_PATH= \
GITSERVER_SSH_KNOWN_HOSTS_PATH= \
STORAGE_CLASS_NAME= \
SITE_CONFIG_PATH= \
./configure/all.sh

find generated -name '*.yaml' -exec kubeval {} +
.buildkite/verify-label.sh
