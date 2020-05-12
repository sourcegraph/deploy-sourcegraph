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
  'add_environment_variable frontend frontend SENTRY_DSN_BACKEND <THE_VALUE>'
  'add_environment_variable frontend frontend SENTRY_DSN_FRONTEND <THE_VALUE>'

  'set_container_image github-proxy github-proxy index.docker.io/sourcegraph/github-proxy:insiders@sha256:3a9e323988309c78c64745b0599e1b4c2b10ddcf2abbdb2283dbde038a4528ba'

  'set_gitserver_replicas 4'
  'set_container_image gitserver gitserver index.docker.io/sourcegraph/gitserver:insiders@sha256:e46e61c702345fb55206b87973f7c6b7f07fac0735201080b5b1e119605ce75c'
  'set_stateful_set_persistent_volume_claim_capacity gitserver repos 1Ti'

  'set_cpu_limit grafana grafana 100m'
  'set_memory_limit grafana grafana 100Mi'
  'set_memory_request grafana grafana 100Mi'
  'set_container_image grafana grafana index.docker.io/sourcegraph/grafana:insiders@sha256:da9678fd7f79afb0b01b2a3f116a208d19c795f77f418186ba3a178055caa94f'
  'add_environment_variable grafana grafana GF_SERVER_ROOT_URL <THE_VALUE>'

  'set_cpu_limit pgsql pgsql 16'
  'set_memory_limit pgsql pgsql 24Gi'
  'set_cpu_request pgsql pgsql 16'
  'set_memory_request pgsql pgsql 24Gi'
  'set_container_image pgsql pgsql index.docker.io/sourcegraph/postgres-11.4:insiders@sha256:63090799b34b3115a387d96fe2227a37999d432b774a1d9b7966b8c5d81b56ad'

  'set_replicas indexed-search 2'
  'set_cpu_limit indexed-search zoekt-webserver 12'
  'set_memory_limit indexed-search zoekt-webserver 120Gi'
  'set_cpu_request indexed-search zoekt-webserver 12'
  'set_memory_request indexed-search zoekt-webserver 120Gi'
  'set_stateful_set_persistent_volume_claim_capacity indexed-search data 4Ti'
  'set_container_image indexed-search zoekt-webserver index.docker.io/sourcegraph/indexed-searcher:insiders@sha256:d8b0fa59f7825acc51ef3cfe9d625019555dceb3272d44b52e396cc7748eaa06'
  'set_container_image indexed-search zoekt-indexserver index.docker.io/sourcegraph/search-indexer:insiders@sha256:fa1eaf045fbd2cab1cd2666046718e47d43012efbe07ad68beda0ac778f62875'

  'set_memory_limit prometheus prometheus 2G'
  'set_memory_request prometheus prometheus 500M'
  'set_container_image prometheus prometheus index.docker.io/sourcegraph/prometheus:insiders@sha256:473a5c94769bf9f73451f6727942202c920d6524f113b9f2cae7edaa033ca552'

  'set_container_image precise-code-intel/api-server precise-code-intel-api-server index.docker.io/sourcegraph/precise-code-intel-api-server:insiders@sha256:aab8c6878c2625ac8a1a337707dd4abdfc321896983fc645ac21585276f60599'
  'set_container_image precise-code-intel/bundle-manager precise-code-intel-bundle-manager index.docker.io/sourcegraph/precise-code-intel-bundle-manager:insiders@sha256:12014e40198bb7b851a79965a67bc577ac4b491a77254ccf32ee3b1836421ce7'
  'set_container_image precise-code-intel/worker precise-code-intel-worker index.docker.io/sourcegraph/precise-code-intel-worker:insiders@sha256:bc93f677e18f8f1cc63725e660e877b601465962676abd43f4fb8947783ce135'

  'set_container_image query-runner query-runner index.docker.io/sourcegraph/query-runner:insiders@sha256:55d85a1315b2ec52c38a70671bc908a114cd5ad89fd2eadc95eb7208c69c952a'

  'set_container_image redis/redis-cache redis-cache index.docker.io/sourcegraph/redis-cache:insiders@sha256:7820219195ab3e8fdae5875cd690fed1b2a01fd1063bd94210c0e9d529c38e56'
  'set_container_image redis/redis-store redis-store index.docker.io/sourcegraph/redis-store:insiders@sha256:e8467a8279832207559bdfbc4a89b68916ecd5b44ab5cf7620c995461c005168'

  'set_container_image replacer replacer index.docker.io/sourcegraph/replacer:insiders@sha256:624b11db92d0a7fd281c28aa4c3723818f7145413dbedd1ef280a77d19123db5'

  'set_container_image repo-updater repo-updater index.docker.io/sourcegraph/repo-updater:insiders@sha256:868f2ee00d3fdc58b164b2f802e1f7ba8404c8e88364b0cf4c89a1339c3702d3'

  'set_container_image searcher searcher index.docker.io/sourcegraph/searcher:insiders@sha256:df4a648676bc7e5d49cac3b1de0b6b8550c2fd9a6a0b3953efe1ea40fe371b0e'

  'set_container_image symbols symbols index.docker.io/sourcegraph/symbols:insiders@sha256:59f8e39244d9a777b5d8f36a8686b470499bc465b35a5f2f07f3979c43da1a80'

  'set_container_image syntect-server syntect-server index.docker.io/sourcegraph/syntax-highlighter:insiders@sha256:aa93514b7bc3aaf7a4e9c92e5ff52ee5052db6fb101255a69f054e5b8cdb46ff'

)
