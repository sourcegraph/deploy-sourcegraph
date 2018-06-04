#!/bin/bash
#
# Re-generates all the k8s config in each example directory

cd "$(dirname "${BASH_SOURCE[0]}")"

function generate() {
    example="$1"
    rm -rf "${example}/generated"
    mkdir -p "${example}/generated"
    helm template --namespace default -f "${example}/values.yaml" ../ --output-dir "${example}/generated"
}

if [ -z "$EXAMPLE" ]; then
    for example in $(ls | grep -v $(basename ${BASH_SOURCE[0]})); do
        generate "$example"
    done
else
    generate "$EXAMPLE"
fi
