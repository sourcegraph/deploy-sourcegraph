# cAdvisor

[cAdvisor](https://github.com/google/cadvisor) provides container users an understanding of the resource usage and performance characteristics of their running containers. It is a running daemon that collects, aggregates, processes, and exports information about running containers.

cAdvisor is part of the default Sourcegraph cluster installation, and deployed as a [Kubernetes DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). This setup is based on the [official cAdvisor Kubernetes Daemonset configuration](https://github.com/google/cadvisor/tree/master/deploy/kubernetes). We use our own cAdvisor deployment over the built-in metrics exported by Kubernetes because the latter is often outdated and needs to be kept in sync with our [Docker-Compose deployments](https://docs.sourcegraph.com/admin/install/docker-compose). This setup allows us to have standard dashboards across all Sourcegraph deployments.

Note that the `sourcegraph/cadvisor` Docker images come with a set of default flags to help reduce memory usage and load on Prometheus - see [our Dockerfile](https://github.com/sourcegraph/sourcegraph/blob/master/docker-images/cadvisor/Dockerfile) for more details.
