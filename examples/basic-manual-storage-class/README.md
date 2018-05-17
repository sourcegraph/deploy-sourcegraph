# Basic example with no storage class

This example sets `cluster.storageClass.create: "none"`, which means
the user must manually add a StorageClass with name "default" to the
cluster.

The StorageClass configuration depends on the underlying
infrastructure provider, so this is a good catch-all example for
infrastructure providers for which this Helm chart does not yet supply
a StorageClass automatically.
