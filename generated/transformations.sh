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
export -f remove_rbac

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
export -f set_namespace

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
export -f ingress_node_port

# set_replicas $SUBSTRING_MATCH $REPLICA_COUNT sets the replica count of deployments and
# statefulsets whose filename matches a substring.
function set_replicas() {
  filename_matcher="$1"
  replica_count="$2"
  filename="$3"

  file_contents=$(cat -)

  echo "$file_contents" | _set_generic "$filename_matcher" "Deployment,StatefulSet" "spec.replicas" "$replica_count" "$filename"
}
export -f set_replicas

function set_gitserver_replicas() {
  local replica_count="$1"
  local filename="$2"

  local file_contents
  file_contents=$(cat -)

  file_contents=$(echo "$file_contents" | set_replicas "/gitserver.StatefulSet.yaml" "$replica_count" "$filename")

  local SRC_GIT_SERVERS_ADDRESSES=()
  for ((i = 0; i < "$replica_count"; i++)); do
    SRC_GIT_SERVERS_ADDRESSES+=("gitserver-${i}.gitserver:3178")
  done

  if [[ $filename == *"/sourcegraph-frontend.Deployment.yaml"* ]]; then
    echo "$file_contents" |
      yq w - "spec.template.spec.containers.(name==frontend).env.(name==SRC_GIT_SERVERS).value" "${SRC_GIT_SERVERS_ADDRESSES[*]}"
    return
  fi
  echo "$file_contents"
}
export -f set_gitserver_replicas

function set_container_image() {
  local filename_matcher="$1"
  local container_name="$2"

  local image="$3"

  local filename="$4"

  file_contents=$(cat -)

  echo "$file_contents" | _set_generic "$filename_matcher" "Deployment,StatefulSet" "spec.template.spec.containers.(name==${container_name}).image" "$image" "$filename"
}
export -f set_container_image

function set_cpu_limit() {
  local filename_matcher="$1"
  local container_name="$2"

  local cpu_value="$3"

  local filename="$4"

  file_contents=$(cat -)

  container_path_expression="$(_generic_container_path_expression "$container_name")"

  echo "$file_contents" | _set_generic "$filename_matcher" "Deployment,StatefulSet" "${container_path_expression}.resources.limits.cpu" "$cpu_value" "$filename"
}
export -f set_cpu_limit

function set_cpu_request() {
  local filename_matcher="$1"
  local container_name="$2"

  local cpu_value="$3"

  local filename="$4"

  file_contents=$(cat -)

  container_path_expression="$(_generic_container_path_expression "$container_name")"

  echo "$file_contents" | _set_generic "$filename_matcher" "Deployment,StatefulSet" "${container_path_expression}.resources.requests.cpu" "$cpu_value" "$filename"
}
export -f set_cpu_request

function set_memory_request() {
  local filename_matcher="$1"
  local container_name="$2"

  local cpu_value="$3"

  local filename="$4"

  file_contents=$(cat -)

  container_path_expression="$(_generic_container_path_expression "$container_name")"

  echo "$file_contents" | _set_generic "$filename_matcher" "Deployment,StatefulSet" "${container_path_expression}.resources.requests.memory" "$cpu_value" "$filename"
}
export -f set_memory_request

function set_memory_limit() {
  local filename_matcher="$1"
  local container_name="$2"

  local cpu_value="$3"

  local filename="$4"

  file_contents=$(cat -)

  container_path_expression="$(_generic_container_path_expression "$container_name")"

  echo "$file_contents" | _set_generic "$filename_matcher" "Deployment,StatefulSet" "${container_path_expression}.resources.limits.memory" "$cpu_value" "$filename"
}
export -f set_memory_limit

function _generic_container_path_expression() {
  local container_name="$1"
  printf "spec.template.spec.containers.(name==%s)" "$container_name"
}
export -f _generic_container_path_expression

export VOLUME_CAPACITY_PATH_EXPRESSION="spec.resources.requests.storage"

function set_stateful_set_persistent_volume_claim_capacity() {
  local filename_matcher="$1"

  local volume_name="$2"
  local volume_capacity="$3"

  local filename="$4"

  file_contents=$(cat -)

  echo "$file_contents" | _set_generic "$filename_matcher" "StatefulSet" "spec.volumeClaimTemplates.(metadata.name==${volume_name}).${VOLUME_CAPACITY_PATH_EXPRESSION}" "$volume_capacity" "$filename"
}
export -f set_stateful_set_persistent_volume_claim_capacity

function set_persistent_volume_claim_capacity() {
  local filename_matcher="$1"

  local volume_capacity="$2"

  local filename="$3"

  file_contents=$(cat -)

  echo "$file_contents" | _set_generic "$filename_matcher" "PersistentVolumeClaim" "${VOLUME_CAPACITY_PATH_EXPRESSION}" "$volume_capacity" "$filename"
}
export -f set_stateful_set_persistent_volume_claim_capacity

function add_environment_variable() {
  local filename_matcher="$1"
  local container_name="$2"

  local variable_name="$3"
  local variable_value="$4"

  local filename="$5"

  file_contents=$(cat -)

  file_contents=$(echo "$file_contents" | _set_generic "$filename_matcher" "Deployment,StatefulSet" "spec.template.spec.containers.(name==${container_name}).env[+].name" "$variable_name" "$filename")
  echo "$file_contents" | set_environment_variable "$filename_matcher" "$container_name" "$variable_name" "$variable_value" "$filename"
}
export -f add_environment_variable

function set_environment_variable() {
  local filename_matcher="$1"
  local container_name="$2"

  local variable_name="$3"
  local variable_value="$4"

  local filename="$5"

  file_contents=$(cat -)
  echo "$file_contents" | _set_generic "$filename_matcher" "Deployment,StatefulSet" "spec.template.spec.containers.(name==${container_name}).env.(name==${variable_name}).value" "$variable_value" "$filename"
}
export -f set_environment_variable

function set_annotation() {
  local filename_matcher="$1"
  local kind="$2"

  local annotation_name="$3"
  local annotation_value="$4"

  local filename="$5"

  file_contents=$(cat -)
  echo "$file_contents" | _set_generic "$filename_matcher" "$kind" "metadata.annotations.\"${annotation_name}\"" "$annotation_value" "$filename"
}
export -f set_annotation

function set_frontend_ingress_ssl() {
  local domain_name="$1"
  local secret_name="$2"

  local filename="$3"

  file_contents=$(cat -)

  file_contents=$(echo "$file_contents" | _set_generic frontend Ingress "spec.rules[0].host" "$domain_name" "$filename")

  file_contents=$(echo "$file_contents" | _set_generic frontend Ingress "spec.tls[+]" hosts "$filename")
  file_contents=$(echo "$file_contents" | _set_generic frontend Ingress "spec.tls[0].hosts[+]" "$domain_name" "$filename")
  file_contents=$(echo "$file_contents" | _set_generic frontend Ingress "spec.tls[0].secretName" "$secret_name" "$filename")

  echo "$file_contents"
}
export -f set_frontend_ingress_ssl

function _set_generic() {
  local filename_matcher="$1"

  local kinds="$2"

  local path_expression="$3"
  local value="$4"

  local filename="$5"

  local file_contents
  file_contents="$(cat -)"

  if [[ ! "$filename" == *"$filename_matcher"* ]]; then
    echo "$file_contents"
    return
  fi

  IFS=',' read -r -a allowed_kinds <<<"$kinds"
  kind=$(echo "$file_contents" | yq r - "kind")

  if ! elementIn "_ALL_" "${allowed_kinds[@]}" && ! elementIn "$kind" "${allowed_kinds[@]}"; then
    echo "$file_contents"
    return
  fi

  echo "$file_contents" | yq w - "${path_expression}" "${value}"
}
export -f _set_generic

# https://stackoverflow.com/a/8574392
elementIn() {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}
export -f elementIn
