#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"

./examples/generate.sh
./test-cases/generate.sh
