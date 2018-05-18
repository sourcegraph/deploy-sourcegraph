#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"

VERSION="$1"
LATEST="${LATEST:-true}"

if [ -z "$VERSION" ] || [ "$VERSION" = "-h" ] || [ "$VERSION" = "--help" ]; then
    cat <<'EOF'
Usage: LATEST={true(default)|false} ./release.sh X.Y.Z

  This script cuts a new release of Sourcegraph Data Center (optionally tagging it as the latest version).
  It performs the following actions:

  * Check out a temporary branch `release-tmp-branch`
  * Writes= the version to the Chart.yaml and commit this change.
  * `git tag` the revision as "vX.Y.Z" and push it upstream.
  * Check out the previously checked-out revision and delete `release-tmp-branch`.
  * Unless LATEST=false, `git tag` and push upstream the new version as the `latest` tag.
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

set -ex
if [ "$LATEST" = "true" ]; then
    git tag -d latest > /dev/null || true
    git tag latest "v${VERSION}"
    git push -f origin latest
    set +ex
    echo "Sourcegraph Data Center ${VERSION} tagged as latest."
fi
