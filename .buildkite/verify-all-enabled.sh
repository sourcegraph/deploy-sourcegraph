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

# Test all configuration scripts enabled.

# For environment vars that take a file path, the generated yaml
# should be valid regardless of what the file contents are,
# so simply pass this script in.
FILEPATH=.buildkite/verify-all-enabled.sh

BASE=generated \
KUBERNETES_NAMESPACE=kns \
JAEGER_ENABLED=y \
LANGUAGE_SERVERS=go,java,javascript,php,python,typescript \
EXPERIMENTAL_LANGUAGE_SERVERS=bash,clojure,cpp,cs,css,dockerfile,elixir,html,lua,ocaml,r,ruby,rust \
PROMETHEUS_ENABLED=y \
PROMETHEUS_EXTRA_RULES_PATH=$FILEPATH \
ALERT_MANAGER_CONFIG_PATH=$FILEPATH \
ALERT_MANAGER_URL=https://example.com \
SSD_NODE_PATH=$FILEPATH \
FRONTEND_TLS_CERTIFICATE_PATH=$FILEPATH \
FRONTEND_TLS_PRIVATE_KEY_PATH=$FILEPATH \
GITSERVER_REPLICA_COUNT=3 \
GITSERVER_SSH_PRIVATE_KEY_PATH=$FILEPATH \
GITSERVER_SSH_KNOWN_HOSTS_PATH=$FILEPATH \
STORAGE_CLASS_NAME=storageclassname \
SITE_CONFIG_PATH=$FILEPATH \
./configure/all.sh

find generated -name '*.yaml' -exec kubeval {} +
.buildkite/verify-label.sh
