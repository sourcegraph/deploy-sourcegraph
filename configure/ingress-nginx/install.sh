#!/bin/sh

set -ex

cd "$(dirname ${BASH_SOURCE[0]})"

kubectl apply -f ingress-nginx.yaml
