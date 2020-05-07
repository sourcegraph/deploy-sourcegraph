#!/usr/bin/env bash

set -ex

cd "$(dirname "${BASH_SOURCE[0]}")"

kubectl apply -f mandatory.yaml # this should be deployed first so that the namespace is created
kubectl apply -f cloud-generic.yaml
