DO NOT REMOVE

This directory contains the required files to include in your Overlay for creating a valid Sourcegraph deployment.

## Plugins

To build with a plugin:

```bash
 kustomize build --enable-alpha-plugins --enable-exec new/plugins/example -o new/generated-cluster.yaml
```
