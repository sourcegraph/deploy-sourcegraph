#!/bin/bash
#
# Re-generates all the k8s config in each example directory

for example in $(echo "basic-gcp basic-aws"); do
    rm -rf "${example}/generated"
    mkdir -p "${example}/generated"
    helm template -f "${example}/values.yaml" ../ --output-dir "${example}/generated"
done
