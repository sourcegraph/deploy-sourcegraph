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
    cat - | yq w - "metadata.namespace" "$namespace"
    return
  fi
  cat -
}

# ingress_node_port exposes the frontend as NodePort Service
function ingress_node_port() {
  port="$1"
  filename="$2"

  if [[ $filename == *"/sourcegraph-frontend.Service.yaml" ]]; then
    cat - |
      yq w - "spec.type" "NodePort" |
      yq d - "spec.ports" |
      yq w - "spec.ports[0].name" "http" |
      yq w - "spec.ports[0].targetPort" "http" |
      yq w - "spec.ports[0].port" "30080" |
      yq w - "spec.ports[0].nodePort" "$port"
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

  if [[ $filename == *"$filename_matcher"* && ($filename == *".Deployment.yaml" || $filename == *".StatefulSet.yaml") ]]; then
    cat - |
      yq w - "spec.replicas" "$replica_count"
    return
  fi
  cat -
}

function set_gitserver_replicas() {
  local replica_count="$1"
  local filename="$2"

  local fileContents
  fileContents=$(cat -)

  fileContents=$(echo "$fileContents" | set_replicas "/gitserver.StatefulSet.yaml" "$replica_count" "$filename")

  local SRC_GIT_SERVERS_ADDRESSES=()
  for ((i = 0; i < "$replica_count"; i++)); do
    SRC_GIT_SERVERS_ADDRESSES+=("gitserver-${i}.gitserver:3178")
  done

  if [[ $filename == *"/sourcegraph-frontend.Deployment.yaml"* ]]; then
    echo "$fileContents" |
      yq w - "spec.template.spec.containers.(name==frontend).env.(name==SRC_GIT_SERVERS).value" "${SRC_GIT_SERVERS_ADDRESSES[*]}"
    return
  fi
  echo "$fileContents"
}
