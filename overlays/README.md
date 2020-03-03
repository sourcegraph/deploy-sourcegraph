# Overlays for kustomizations

This directory contains overlays for various [kustomizations](https://kustomize.io/). kustomize has become a standard way
to specialize a set of Kubernetes YAML config files for different cluster setups, environments and other parametrizations.
Starting with client version 1.14 of `kubectl` it is built into kubectl itself and can be used with the `apply` command
and the flag `-k` instead of flag `-f`.

If your kubectl version is older and doesn't support `apply -k` you can still use these kustomizations. You need to 
install the standalone [kustomize](https://kustomize.io/) binary, generate the YAML files with `kustomize build` and
then use the built YAML with `kubectl apply -f`. For example:

```shell script
cd overlays/namespaced
kustomize build | kubectl apply -f -
```


 

