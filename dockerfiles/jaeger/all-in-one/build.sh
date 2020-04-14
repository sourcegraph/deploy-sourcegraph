#!/bin/bash

set -euo pipefail

. version.sh

echo "Building image for Jaeger $VERSION"

docker build --build-arg JAEGER_VERSION="$VERSION" . -t "sourcegraph/jaeger-all-in-one:$VERSION"
