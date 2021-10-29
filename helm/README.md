# USE AT YOUR OWN RISK

This is a prototype only intended for non-production proof of concepts and support is not guaranteed.

Provided here is a very basic helm chart derived from the base manifests at https://github.com/sourcegraph/deploy-sourcegraph/tree/v3.33.0.

Minimal configuration is currently available, but required changes can be made directly to the manifests before publishing to the registry.

## Storage Class

This chart includes a storage class defined in templates/sourcegraph.StorageClass.yaml. It is currently configured to allow provisioning SSDs in GCP, but should be edited to meet your own requirements.

If you are unable to install a storageClass, you can disable storageClass creation in the values.yaml file and provide your own existing storageClass name instead.
