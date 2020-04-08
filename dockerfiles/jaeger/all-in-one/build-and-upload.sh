#!/bin/bash

set -euo pipefail

VERSION="${VERSION:-1.17.1}"

echo "Building image for Jaeger $VERSION"

docker build --build-arg JAEGER_VERSION="$VERSION" . -t "sourcegraph/jaeger-all-in-one:$VERSION"
docker push "sourcegraph/jaeger-all-in-one:$VERSION"
