# Executors

Executors are Sourcegraph’s solution for running untrusted code in a secure and controllable way. For more information on executors and how they are used see the Executors [documentation](https://docs.sourcegraph.com/admin/executors)

## Deploying

This directory contains manifests for the optional deployment of Sourcegraph Executors on Kubernetes.

It is expected that all components contained in this directory and any subdirectories are deployed to ensure full functionality and best performance.

The following components will deployed:

- [Executor Deployment](./executor/executor.Deployment.yaml) An Executor replica with a Docker sidecar to run isolated batch changes and auto-indexing jobs. This deployment requires a [privileged security context](https://kubernetes.io/docs/concepts/security/pod-security-standards/).
- [Executor Service](./executor/executor.Service.yaml) A headless service for executor metrics access. Executors are not externally accessible.
- [Docker ConfigMap](./executor/docker-daemon.ConfigMap.yaml) configuration for the docker sidecar to use the pull-through cache.
- [Private docker registory]
  - [Registry Deployment](./private-docker-registry/private-docker-registry.Deployment.yaml) A private docker registry configured as a pull-through cache to avoid docker hub rate limiting.
  - [Registry Service](./private-docker-registry/private-docker-registry.Service.yaml) A service to access the private-docker-registry.
  - [Registry Persistent Volume](./private-docker-registry/private-docker-registry.PersistentVolumeClaim.yaml) A volume to store images in the private-docker-registry.

To apply these manifests, run the following command:

```bash
kubectl apply -f . --recursive
```

