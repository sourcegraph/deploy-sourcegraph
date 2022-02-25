#!/usr/bin/env bash

# Run basic pre-flights to ensure Sourcegraph can be installed into a cluster
#

# --- helper functions for logs ---
info() {
  echo '[INFO] ' "$@"
}
warn() {
  echo '[WARN] ' "$@" >&2
}
fatal() {
  echo '[ERROR] ' "$@" >&2
  exit 1
}

echo "Running pre-flight checks"

kubectl get storageclass 'sourcegraph' || fatal "Cannot find Sourcegraph storage class"
kubectl get namespace 'sourcegraph' || warn "Installing to a dedicated namespace is preferred"

echo "Pre-flight successful, you are ready to search!"
