#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"

VERSION="$1"
LATEST="${LATEST:-true}"

if [ -z "$VERSION" ] || [ "$VERSION" = "-h" ] || [ "$VERSION" = "--help" ]; then
    cat <<'EOF'
Usage: LATEST={true(default)|false} ./release.sh X.Y.Z
  This script cuts a new release of Sourcegraph Data Center (optionally tagging it as the latest version).
EOF
    exit 1
fi

if [ "$LATEST" = "true" ]; then
    echo -n "Is the commit you wish to release as version $VERSION (and LATEST) currently checked out? [y/N] "
else
    echo -n "Is the commit you wish to release as version $VERSION (NOT latest) currently checked out? [y/N] "
fi
read shouldProceed
if [ "$shouldProceed" != "y" ] && [ "$shouldProceed" != "Y" ]; then
    echo "Aborting."
    exit 1
fi

if [ ! -z "$(git status --porcelain)" ]; then
    echo "You have a dirty working directory. Aborting."
    exit 1
fi

SEMVER="v${VERSION}"
git tag $SEMVER
git push origin $SEMVER

echo "Sourcegraph Data Center ${VERSION} published."

if [ "$LATEST" = "true" ]; then
    git tag -d latest > /dev/null || true
    git tag latest $SEMVER
    git push -f origin latest
    echo "Sourcegraph Data Center ${VERSION} tagged as latest."
fi