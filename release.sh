#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"

VERSION="$1"

if [ -z "$VERSION" ] || [ "$VERSION" = "-h" ] || [ "$VERSION" = "--help" ]; then
    cat <<'EOF'
Usage: ./release.sh X.Y.Z
EOF
    exit 1
fi

echo -n "Is the commit you wish to release as version $VERSION currently checked out? [y/N] "
read shouldProceed

if [ "$shouldProceed" != "y" ] && [ "$shouldProceed" != "Y" ]; then
    echo "Aborting."
    exit 1
fi

if [ ! -z "$(git status --porcelain)" ]; then
    echo "You have a dirty working directory. Aborting."
    exit 1
fi

set -ex

# Write $VERSION to Chart.yaml and tag that revision as $VERSION
CURRENT_REV="$(git symbolic-ref HEAD 2> /dev/null || git rev-parse HEAD)"
CURRENT_REV="${CURRENT_REV#refs/heads/}"
git branch -D release-tmp-branch &> /dev/null || true
git checkout HEAD -b release-tmp-branch
cat <<EOF > Chart.yaml
name: sourcegraph
version: ${VERSION}
home: https://sourcegraph.com
EOF
git commit -a -m "Release ${VERSION}"
git tag "v${VERSION}"
git checkout "$CURRENT_REV"
git branch -D release-tmp-branch &> /dev/null || true

# Push up the tag $VERSION
git push origin "v${VERSION}"

set +ex
echo "Sourcegraph Data Center ${VERSION} published."
