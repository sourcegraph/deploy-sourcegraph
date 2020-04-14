#!/bin/bash

set -euo pipefail

. version.sh

echo "Uploading image for Jaeger $VERSION"

docker push "sourcegraph/jaeger-all-in-one:$VERSION"
