# Migrating from Data Center 2.10.x or prior

Two things have changed in 2.11.x that require migration:

- Gitserver is now configured using StatefulSet. To avoid losing all cached git data some [manual steps are required](#StatefulSet-migration) to preserve the PersistentVolumes that this data is stored on.
- We have a [new deployment strategy](#Deployment-migration).

There are two migration paths:

1. Update directly to 2.11.x and perform both migrations at once.
2. First update to 2.11.x-deprecated-helm to perform the [StatefulSet migration](#StatefulSet-migration), then update to 2.11.x to use the [new deployment strategy](#Deployment-migration).

2.12.x will only be available using the new deployment strategy.

## StatefulSet migration

_Required when deploying 2.11.x or 2.11.x-deprecated-helm_

## Deployment migration

_Required when deploying 2.11.x_

### The old way

2.10.x and prior was deployed by configuring `values.yaml` and using `helm` to generate the final yaml to deploy to a cluster.

There were a few downsides with this approach:

- `values.yaml` was a custom configuration format defined by us which implicitly made configuring certain Kubernetes settings special cases. We didn't want this to grow over time into an unmaintainable/unusable mess.
- If customers wanted to configure things not supported in `values.yaml`, then we would either need to add support or the customer would need to make further modifications to the generated yaml.
- Writing Go templates inside of yaml was error prone and hard to maintain. It was too easy to make a silly mistake and generate invalid yaml. Our editors could not help us because Go template logic made the yaml templates not valid yaml.
- It required using `helm` to generate templates even though some customers don't care to use `helm` to deploy the yaml.

### The new way

Our new approach is simpler and more flexible.

- We have removed our dependency on `helm`. It is no longer needed to generate templates, and we no longer recommend it as the easiest way to deploy our yaml to a cluster. You are still free to use `helm` to deploy to your cluster if you wish.
- Our base config is pure yaml which can be deployed directly to a cluster. It is easier for you to use, and also easier for us to maintain.
- You can configure our base yaml using whatever process best for you (Git ops, [Kustomize](https://github.com/kubernetes-sigs/kustomize), custom scripts, etc.). We provide [documentation and recipies for common customizations](customization.md).

### Steps to migrate

TODO(nick,geoffrey)
