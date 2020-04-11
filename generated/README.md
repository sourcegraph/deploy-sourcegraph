# Generated cluster

This directory contains a script that generates a cluster from source manifests by applying a series of transformations.

1. Modify `params.sh` to determine the source manifests and transformations used to generate the cluster.
1. Run `./generate.sh` to generate a cluster in a subdirectory, `generated-cluster`.
1. View the diff between the generated cluster base and the base source manifests: `diff -ur ../base
   ./generated-cluster/base | colordiff | less -R` (this ignores any additional sources added
   outside of `base`).
