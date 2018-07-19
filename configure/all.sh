#!/bin/bash
# Runs all configuration scripts.

set -e

cd "$(dirname "${BASH_SOURCE[0]}")/.."

./configure/xlang/xlang.py
./configure/ssd/ssd.sh
./configure/config-file.sh
./configure/frontend-tls.sh
./configure/gitserver-replicas.sh
./configure/gitserver-ssh.sh
./configure/storage-class-name.sh
./configure/jaeger/jaeger.sh
./configure/prometheus/prometheus.sh