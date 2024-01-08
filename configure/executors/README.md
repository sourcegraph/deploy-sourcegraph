# Executors

Executors are Sourcegraph’s solution for running untrusted code in a secure and controllable way. For more information on executors and how they are used see the Executors [documentation](https://docs.sourcegraph.com/admin/executors)

## Deploying

This directory contains manifests for the optional deployment of Sourcegraph Executors on Kubernetes.

It is expected that all components contained in this directory and any subdirectories are deployed to ensure full functionality and best performance.

There are two distribution methods supported:

### Native Kubernetes Executors (Recommended)

Requirements: RBAC, persistent volumes

This distribution method makes use of native Kubernetes Deployments, Services, and Jobs to execute workloads. It is suitable for clusters that meet Sourcegraph's minimum requirements.

The following components will deployed:

- [Executor Deployment](./executor/k8s/executor.Deployment.yaml) An Executor replica with a Docker sidecar to run isolated batch changes and auto-indexing jobs. This deployment requires a [privileged security context](https://kubernetes.io/docs/concepts/security/pod-security-standards/).
- [Executor Service](./executor/k8s/executor.Service.yaml) A headless service for executor metrics access. Executors are not externally accessible.
- [Executor ConfigMap](./executor/k8s/executor.ConfigMap.yaml) configuration for the Executor deployment
- RBAC
  - [Role](./executor/k8s/rbac/executor.Role.yaml)
  - [RoleBinding](./executor/k8s/rbac/executor.RoleBinding.yaml)
  - [ServiceAccount](./executor/k8s/rbac/executor.ServiceAccount.yaml)
- [Private docker registory]
  - [Registry Deployment](./private-docker-registry/private-docker-registry.Deployment.yaml) A private docker registry configured as a pull-through cache to avoid docker hub rate limiting.
  - [Registry Service](./private-docker-registry/private-docker-registry.Service.yaml) A service to access the private-docker-registry.
  - [Registry Persistent Volume](./private-docker-registry/private-docker-registry.PersistentVolumeClaim.yaml) A volume to store images in the private-docker-registry.

To apply these manifests, run the following command:

```bash
kubectl apply -f . --recursive private-docker-registry
kubectl apply -f . --recursive k8s
```

### Docker-in-Docker Kubernetes Executors

Requirements: elevated permissions, persistent volumes

This distribution method makes use of a docker-in-docker sidecar container to execute the workloads. It is suitable for clusters that meet Sourcegraph's minimum requirements that cannot utilize native Kubenretes executors.

The following components will deployed:

- [Executor Deployment](./executor/dind/executor.Deployment.yaml) An Executor replica with a Docker sidecar to run isolated batch changes and auto-indexing jobs. This deployment requires a [privileged security context](https://kubernetes.io/docs/concepts/security/pod-security-standards/).
- [Executor Service](./executor/dind/executor.Service.yaml) A headless service for executor metrics access. Executors are not externally accessible.
- [Docker ConfigMap](./executor/dind/docker-daemon.ConfigMap.yaml) configuration for the docker sidecar to use the pull-through cache.
- [Private docker registory]
  - [Registry Deployment](./private-docker-registry/private-docker-registry.Deployment.yaml) A private docker registry configured as a pull-through cache to avoid docker hub rate limiting.
  - [Registry Service](./private-docker-registry/private-docker-registry.Service.yaml) A service to access the private-docker-registry.
  - [Registry Persistent Volume](./private-docker-registry/private-docker-registry.PersistentVolumeClaim.yaml) A volume to store images in the private-docker-registry.

To apply these manifests, run the following command:

```bash
kubectl apply -f . --recursive private-docker-registry
kubectl apply -f . --recursive dind
```
