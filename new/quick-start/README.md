# Quick Start

This directory provides overlays that are ready to use for installing a pre-configured Sourcegraph instance.

## Basic

You can use the overlays in the `basic` directory to deploy the main Sourcegraph stack without the monitoring stacks which requires RBACs enabled in your cluster.

## Full

You can use the overlays in the `full` directory to deploy the main Sourcegraph stack with the monitoring stacks that requires RBACs enabled in your cluster.

IMPORTANT: For clusters that do not allow RBACs resources, please deploy using the overlays in the `basic` directory instead.

## How to use

### Basic

To deploy the main Sourcegraph stacks only, use an overlay for your instance size inside the basic directory.

Run the following command to build the manifests with the overlay of your choice.

You should replace `xs` with your instance size.

```bash
# You can replace `new/generated-cluster.yaml` to any file path.
kubectl kustomize new/quick-start/basic/xs -o new/generated-cluster.yaml
```

You can then deploy using the newly generated manifests in the `new/generated-cluster.yaml` file by running:

```bash
kubectl apply -f new/generated-cluster.yaml
```

### Full

To deploy the full Sourcegraph stacks, use an overlay for your instance size inside the full directory.

Run the following command to build the manifests with the overlay of your choice.

You should replace `xs` with your instance size.

```bash
# You can replace `new/generated-cluster.yaml` to any file path.
kubectl kustomize new/quick-start/full/xs -o new/generated-cluster.yaml
```

You can then deploy using the newly generated manifests in the `new/generated-cluster.yaml` file by running:

```bash
kubectl apply -f new/generated-cluster.yaml
```
