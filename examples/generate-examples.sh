#!/bin/bash
#
# Re-generates all the k8s config in each example directory

cd "$(dirname "${BASH_SOURCE[0]}")"

function generate() {
    example="$1"
    rm -rf "${example}/generated"
    mkdir -p "${example}/generated"
    helm template -f "${example}/values.yaml" ../ --output-dir "${example}/generated"
}

if [ -z "$EXAMPLE" ]; then
    for example in $(ls | grep -v generate-examples.sh); do
        generate "$example"
    done
else
    generate "$EXAMPLE"
fi
