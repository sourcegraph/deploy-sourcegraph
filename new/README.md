# [WIP] Sourcegraph Kustomize

This repository contains a set of Kustomize components and overlays that are designed to work with the [Sourcegraph Kubernetes deployment repository](https://sourcegraph.com/github.com/sourcegraph/deploy-sourcegraph), and to replace the [older version of the overlays](https://sourcegraph.com/github.com/sourcegraph/deploy-sourcegraph/-/tree/overlays).

The new set of Kustomize components and overlays provide more flexibility in creating an overlay that suits your deployments and eliminates the need to clone the deployment repository.

IMPORTANT: Only works with Sourcegraph version v4.4.0+ (TBC)

## Overview

[Kustomize](https://kustomize.io/) is built into `kubectl` in version >= 1.14.

### File structure

- base
  - contains manifests with the default value for all Sourcegraph services
- components
  - contains preconfigured components that are created for different purposes, and are ready to be used in an overlay
- overlays
  - the default directory for building a customized overlay for your Sourcegraph deployment
- quick-start
  - contains different ready-to-use overlays built for different use cases

## How to use

See our [Kustomize docs](https://docs.sourcegraph.com/admin/deploy/kubernetes/kustomize) on detailed instructions.
