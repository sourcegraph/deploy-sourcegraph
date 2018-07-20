#!/bin/bash

set -e

cd "$(dirname "${BASH_SOURCE[0]}")/../.."

./configure/util/require-basedir.sh

find $BASEDIR -name "*.yaml" -exec sh -c "cat {} | yj | jy -o {}" \;
