#!/usr/bin/env bash

INPUT_SOURCE_DIRS=( "base" )
INPUT_SOURCE_FILES=()
TRANSFORMATIONS=(
  'remove_rbac'
  'set_namespace * ns-sourcegraph'
  'ingress_node_port 30080'
  'set_replicas frontend 5'
  'set_replicas searcher 10'
)
