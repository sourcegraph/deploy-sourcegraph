#!/usr/bin/env bash

export INPUT_SOURCE_DIRS=("base")
export INPUT_SOURCE_FILES=()
export TRANSFORMATIONS=(
  # 'remove_rbac'
  # 'set_namespace * ns-sourcegraph'
  # 'ingress_node_port 30080'
  # 'set_replicas frontend 5'
  # 'set_replicas searcher 10'
  'set_replicas searcher 5'

  'set_container_image frontend frontend index.docker.io/sourcegraph/frontend:insiders@sha256:81aeefd5dd8b333ee224180767aad142e8308d38ed1fb2d834aefbdcd4652d1d'
  'set_cpu_limit frontend frontend 8000m'
  'set_memory_limit frontend frontend 6G'
  'set_cpu_request frontend frontend 6000m'
  'set_memory_request frontend frontend 4G'
  'add_environment_variable frontend frontend SENTRY_DSN_BACKEND <THE_VALUE>'
  'add_environment_variable frontend frontend SENTRY_DSN_FRONTEND <THE_VALUE>'
  'set_annotation frontend Ingress certmanager.k8s.io/acme-challenge-type http01'
  'set_annotation frontend Ingress certmanager.k8s.io/issuer letsencrypt-prod'
  'set_annotation frontend Ingress nginx.ingress.kubernetes.io/proxy-read-timeout 1d'
  'set_frontend_ingress_ssl k8s.sgdev.org sourcegraph-tls'

  'set_container_image github-proxy github-proxy index.docker.io/sourcegraph/github-proxy:insiders@sha256:d3498406db3493eb252c79948915eac1e1c7223f01f3500bc8b839676042cf88'

  'set_gitserver_replicas 4'
  'set_container_image gitserver gitserver index.docker.io/sourcegraph/gitserver:insiders@sha256:55b5c1c872811e289a0e69abbac3b83a9ce627e7c08f92165f4bdc979d570310'
  'set_stateful_set_persistent_volume_claim_capacity gitserver repos 1Ti'
  'set_gitserver_ssh_credentials gitserver-ssh'

  'set_cpu_limit grafana grafana 100m'
  'set_memory_limit grafana grafana 100Mi'
  'set_memory_request grafana grafana 100Mi'
  'set_container_image grafana grafana index.docker.io/sourcegraph/grafana:insiders@sha256:f3fbf9845f0b65377f90a7a8eac253b90b77f9e53242e559031ccde247836776'
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
  'set_container_image prometheus prometheus index.docker.io/sourcegraph/prometheus:insiders@sha256:d0d80a7598b907624f106deebe5ecd7ba5c16ed47d913abee2085e18331f9a90'

  'set_container_image precise-code-intel/api-server precise-code-intel-api-server index.docker.io/sourcegraph/precise-code-intel-api-server:insiders@sha256:654499ae605b6a1480a7f8aab84dfc621e77214ba849cde12bce10a34bbece5d'
  'set_container_image precise-code-intel/bundle-manager precise-code-intel-bundle-manager index.docker.io/sourcegraph/precise-code-intel-bundle-manager:insiders@sha256:7c38143e1648b3679766984ea75f8dcac4577e3a71768b814860cf12de9f44ff'
  'set_container_image precise-code-intel/worker precise-code-intel-worker index.docker.io/sourcegraph/precise-code-intel-worker:insiders@sha256:9acc4feb17fab17a1c34afa0ac42f930af438bf6ca264a91aa00dccf5eac4ef1'

  'set_container_image query-runner query-runner index.docker.io/sourcegraph/query-runner:insiders@sha256:c1a64022fb07c7ad440f91505daf3833f773198a4313831143b0a8bc580fc848'

  'set_container_image redis/redis-cache redis-cache index.docker.io/sourcegraph/redis-cache:insiders@sha256:7820219195ab3e8fdae5875cd690fed1b2a01fd1063bd94210c0e9d529c38e56'
  'set_container_image redis/redis-store redis-store index.docker.io/sourcegraph/redis-store:insiders@sha256:e8467a8279832207559bdfbc4a89b68916ecd5b44ab5cf7620c995461c005168'

  'set_container_image replacer replacer index.docker.io/sourcegraph/replacer:insiders@sha256:20237ba8463f7b4523e2d651412d0ac4f512c21bb1a5e6553caec2caac6ea54a'

  'set_container_image repo-updater repo-updater index.docker.io/sourcegraph/repo-updater:insiders@sha256:5b2d5f6b62613d7da40c5fa16366fc3aba660426ec102692b7e30a2a3b708b36'

  'set_container_image searcher searcher index.docker.io/sourcegraph/searcher:insiders@sha256:db7b6ed8be158e7f39a72be27310d3ae745e8be99215db52f7ac0a4bc6e830e7'

  'set_container_image symbols symbols index.docker.io/sourcegraph/symbols:insiders@sha256:ea4fcf06a0639e9430eb86c32ce1eed790a581b8c60689cff7618b7a8f4b36ba'

  'set_container_image syntect-server syntect-server index.docker.io/sourcegraph/syntax-highlighter:insiders@sha256:aa93514b7bc3aaf7a4e9c92e5ff52ee5052db6fb101255a69f054e5b8cdb46ff'

)
