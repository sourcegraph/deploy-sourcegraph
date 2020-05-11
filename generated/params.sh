#!/usr/bin/env bash

export INPUT_SOURCE_DIRS=("base")
export INPUT_SOURCE_FILES=()
export TRANSFORMATIONS=(
  'remove_rbac'
  # 'set_namespace * ns-sourcegraph'
  # 'ingress_node_port 30080'
  # 'set_replicas frontend 5'
  # 'set_replicas searcher 10'
  'set_replicas searcher 5'

  'set_container_image frontend frontend index.docker.io/sourcegraph/frontend:insiders@sha256:6a69d89c7973bb286536fa0ff22624818ca51a2f0427dd32809190b940fe557a'
  'set_cpu_limit frontend frontend 8000m'
  'set_memory_limit frontend frontend 6G'
  'set_cpu_request frontend frontend 6000m'
  'set_memory_request frontend frontend 4G'

  'set_container_image github-proxy github-proxy index.docker.io/sourcegraph/github-proxy:insiders@sha256:3a9e323988309c78c64745b0599e1b4c2b10ddcf2abbdb2283dbde038a4528ba'

  'set_gitserver_replicas 4'
  'set_container_image gitserver gitserver index.docker.io/sourcegraph/gitserver:insiders@sha256:e46e61c702345fb55206b87973f7c6b7f07fac0735201080b5b1e119605ce75c'
  'set_container_image gitserver gitserver index.docker.io/sourcegraph/gitserver:insiders@sha256:e46e61c702345fb55206b87973f7c6b7f07fac0735201080b5b1e119605ce75c'

  'set_cpu_limit grafana grafana 100m'
  'set_memory_limit grafana grafana 100Mi'
  'set_memory_request grafana grafana 100Mi'

  'set_cpu_limit pgsql pgsql 16'
  'set_memory_limit pgsql pgsql 24Gi'
  'set_cpu_request pgsql pgsql 16'
  'set_memory_request pgsql pgsql 24Gi'

  'set_replicas indexed-search 2'
  'set_cpu_limit indexed-search zoekt-webserver 12'
  'set_memory_limit indexed-search zoekt-webserver 120Gi'
  'set_cpu_request indexed-search zoekt-webserver 12'
  'set_memory_request indexed-search zoekt-webserver 120Gi'

  'set_memory_limit prometheus prometheus 2G'
  'set_memory_request prometheus prometheus 500M'
)
