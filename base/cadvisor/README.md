# cAdvisor

[cAdvisor](https://github.com/google/cadvisor) provides container users an understanding of the resource usage and performance characteristics of their running containers. It is a running daemon that collects, aggregates, processes, and exports information about running containers.

cAdvisor is part of the default Sourcegraph cluster installation, and deployed as a [Kubernetes Daemonset](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). This setup is based on the [official cAdvisor Kubernetes Daemonset configuration](https://github.com/google/cadvisor/tree/master/deploy/kubernetes).
