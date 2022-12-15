# Kustomize Overlay - Resources Update

This overlay allows you to customize the values for the resources described in the [Sourcegraph resource estimator](https://docs.sourcegraph.com/admin/deploy/resource_estimator) for your instance through a kustomization file.

### Update the resources.yaml file

Look for the names of the services inside the `resources.yaml` file in this directory and update the values for the resources within the file

> IMPORTANT: Make sure the untouched services stay commented or removed, and the services you have made changes to are uncommented.
