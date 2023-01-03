# [WIP] Sourcegraph Kustomize

This repository contains a set of Kustomize components and overlays that are designed to work with the [Sourcegraph Kubernetes deployment repository](https://sourcegraph.com/github.com/sourcegraph/deploy-sourcegraph), and to replace the [older version of the overlays](https://sourcegraph.com/github.com/sourcegraph/deploy-sourcegraph/-/tree/overlays).

The new set of Kustomize components and overlays provide more flexibility in creating an overlay that suits your deployments and eliminates the need to clone the deployment repository.

IMPORTANT: Only works with Sourcegraph version TBA

## Kustomize

[Kustomize](https://kustomize.io/) is built into `kubectl` in version >= 1.14.

### Overlays

An overlay specifies customizations for a base directory of Kubernetes manifests, in this case the [base/](https://sourcegraph.com/github.com/sourcegraph/deploy-sourcegraph@master/-/tree/new/base) directory in the [deploy-sourcegraph repository](https://sourcegraph.com/github.com/sourcegraph/deploy-sourcegraph).

Each overlay is created with different kustomize components that are located inside the components directory.

### Components

A kustomize component is essentially a smaller unit of a normal kustomization, and designed to be reusable. _They are evaluated after the resources of the parent kustomization (overlay or component) have been accumulated, and on top of them. ([source](https://sourcegraph.com/github.com/kubernetes/enhancements@master/-/blob/keps/sig-cli/1802-kustomize-components/README.md#proposal))_

To understand what an overlay does is to check what components the overlay is using. The components are listed under the `components` field inside the `kustomization.yaml` file of an overlay.

## How to use

There are two ways to use any of our overlays:

1. Remote build
2. Local build

### Option 1: Remote build

You can create an overlay to deploy Sourcegraph without cloning the reference repository by using [remote build](https://github.com/kubernetes-sigs/kustomize/blob/master/examples/remoteBuild.md).

#### Generate manifests

Run the following command to generate manifests using the remote URL for one of our overlay, you can replace the $REMOTE_OVERLAY_URL with the remote URL for the overlay of your choice, and replace $PATH_TO_EXISITING_DIRECTORY with the path to an existing directory on your local machine where the newly generated manifests can be found.

```bash
$ kubectl kustomize $REMOTE_OVERLAY_URL -o $PATH_TO_EXISITING_DIRECTORY
```

##### Example

To generate manifests for Sourcegraph version v4.4.0 using the remote URL for our k3s overlay that is configured for a size XS instance, and then send the output files to the `generated-cluster/` directory on your local machine:

```bash
$ mkdir generated-cluster
$ kubectl kustomize https://github.com/sourcegraph/deploy-sourcegraph/new/overlays/quick-start/k3s/xs?ref=v4.4.0 -o generated-cluster/
```

## Apply an overlay

To apply the customizations configured with your overlay:

1. Follow the steps in the `Generate manifests` section above to build manifests from an overlay
2. Make sure the manifests in the output directory `generated-cluster/` are generated correctly
3. Run the following command to apply overlay directly using the remote URL

```bash
$ kubectl apply -k $REMOTE_OVERLAY_URL
```

### Option 2: Local build

If none of the provided overlays fit your needs, or additional changes and customizations are required, then you will need to clone this repository and follow the recommended instructions below to create your own kustomize overlay.

#### Create a new component

If you want to modify an existing component, it is recommended to create a new component instead and make the changes inside the new component. Making changes directly to the existing components are not recommended as it can cause merge conflicts in the future.

Here is an example of a new overlay that is using a new component that does not exist remotely, while still using our deployment repository as base remotely:

```yaml
# kustomization.yaml for the new overlay
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: ns-sourcegraph-example
resources:
  - https://github.com/sourcegraph/deploy-sourcegraph/base?ref=v9.9.9
components:
  # local path to the new component you created within the ./components folder
  - new/kustomize/components/your-new-component
  #   You can also refer to other sourcegraph component that is hosted in other remote repository
  - https://github.com/org/repo/path/to/new/component
```

#### Create a new overlay

Here is an example of what a typical `kustomization.yaml` file that is use to build a Kustomize overlay looks like:

```yaml
# Note: this is the kustomization.yaml file for the minikube overlay
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: ns-sourcegraph-example
resources:
  - new/base/sourcegraph
  - new/base/monitoring
components:
  - new/kustomize/components/minikube
```

This example overlay that has the following features:

- deploy the sourcegraph main-stacks resources from the resources directory
- deploy the sourcegraph monitoring-stacks resources from the resources directory
- apply the `minikube` component from the components directory

See the example overlay inside the overlays directory to learn more about the basic structure when creating a new overlay to deploy Sourcegraph.

#### Generate manifests

This allows you to preview the output files of your overlay before applying the manifests to your cluster.

Run the following command in the root of this repository.

> NOTE: Replace `$PATH_TO_OVERLAY` with the path to the overlay of your choice.

##### Individual output files

To produce seperated manifest file for each resources to the `generated-cluster/` directory:

```bash
# Create a 'generated-cluster' directory
$ mkdir generated-cluster
# Example: kubectl kustomize new/kustomize/overlays/quick-start/basic/xs -o generated-cluster/
$ kubectl kustomize $PATH_TO_OVERLAY -o generated-cluster/
```

##### Single output file

To groups all the manifests into a single file named generated-cluster.yaml` to the root directory:

```bash
# Example: kubectl kustomize new/kustomize/overlays/quick-start/minikube -o generated-cluster.yaml
$ kubectl kustomize $PATH_TO_OVERLAY -o generated-cluster.yaml
```

#### Apply an overlay

To apply the customizations configured with your overlay:

1. Follow the steps in the `Generate manifests` section above to build manifests from an overlay
2. Make sure the manifests in the output directory `generated-cluster/` are generated correctly
3. Run the following command from the root of this repository to apply the manifests from the output directory `generated-cluster/`

```bash
$ kubectl apply -k generated-cluster/
```
