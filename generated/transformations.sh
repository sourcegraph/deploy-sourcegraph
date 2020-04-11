#!/usr/bin/env bash

# Remove RBAC roles from deployment.
function remove_rbac() {
  if [[ $1 == *"/rbac-roles/"* ]]; then
    # echo "removed $1" 1>&2
    echo ""
    return
  fi
  cat -
}

# set_namespace $GLOB $NAMESPACE sets the namespace of all resources in the cluster matching a glob pattern.
function set_namespace() {
  glob="$1"
  namespace="$2"
  filename="$3"

  if [[ $filename == *".Deployment.yaml" && $filename == $glob ]]; then
    cat - | yj | jq ".metadata.namespace = \"$namespace\"" | jy
    return
  fi
  cat -
}

# ingress_node_port exposes the frontend as NodePort Service
function ingress_node_port() {
  port="$1"
  filename="$2"
  read -r -d '' portSpec <<EOF
[
  {
    "name": "http",
    "port": 30080,
    "nodePort": 30080
  }
]
EOF

  if [[ $filename == *"/sourcegraph-frontend.Service.yaml" ]]; then
    cat - | yj \
      | jq ".spec.type = \"NodePort\"" \
      | jq ".spec.ports = $portSpec" \
      | jy
    return
  fi
  cat -
}

# set_replicas $SUBSTRING_MATCH $REPLICA_COUNT sets the replica count of deployments and
# statefulsets whose filename matches a substring.
function set_replicas() {
  filename_matcher="$1"
  replica_count="$2"
  filename="$3"

  if [[ $filename == *"$filename_matcher"* && ( $filename == *".Deployment.yaml" || $filename == *".StatefulSet.yaml" ) ]]; then
    cat - | yj \
      | jq ".spec.replicas = $replica_count" \
      | jy
    return
  fi
  cat -
}
