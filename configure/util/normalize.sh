#!/bin/bash

set -e

cd "$(dirname "${BASH_SOURCE[0]}")/../.."

BASE=${BASE:-base}

find $BASE -name "*.yaml" -exec sh -c "cat {} | yj | jy -o {}" \;
