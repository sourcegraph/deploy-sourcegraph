#!/bin/bash
#
# Re-generates all the k8s config in each example directory

cd "$(dirname "${BASH_SOURCE[0]}")"

for example in $(echo "basic-gcp basic-aws basic-manual-storage-class"); do
    rm -rf "${example}/generated"
    mkdir -p "${example}/generated"
    helm template -f "${example}/values.yaml" ../ --output-dir "${example}/generated"
done
