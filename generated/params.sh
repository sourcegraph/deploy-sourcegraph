#!/usr/bin/env bash

export INPUT_SOURCE_DIRS=("base")
export INPUT_SOURCE_FILES=()
export TRANSFORMATIONS=(
  'remove_rbac'
  # 'set_namespace * ns-sourcegraph'
  # 'ingress_node_port 30080'
  # 'set_replicas frontend 5'
  'set_replicas searcher 10'
  'set_gitserver_replicas 4'
)
