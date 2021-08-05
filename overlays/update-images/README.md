# Update updating

This can be used to update all Sourcegraph images in the case they are mirrored.

__Requires `kustomize` and `ripgrep` on your path__

./set-repo-registry.sh REGISTRY REPO TAG

The images block can be moved to other Kustomize files as needed.