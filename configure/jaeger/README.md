# Jaeger

Jaeger is installed if you followed the standard installation instructions. Its resource objects are
defined in the `base/jaeger` directory. Additionally, a Jaeger agent sidecar container is present in
the `*.Deployment.yaml` and `*.StatefulSet.yaml` of certain services.

## Connect Sourcegraph to an external Jaeger instance

If you have an existing Jaeger instance you would like to connect Sourcegraph to (instead of running
the Jaeger instance inside the Sourcegraph cluster), do:

1. Remove the `base/jaeger` directory: `rm -rf base/jaeger`
1. Update the Jaeger agent containers to point to your Jaeger collector.
   1. Find all instances of Jaeger agent (`grep -R 'jaegertracing/jaeger-agent'`).
   1. Update the `args` field of the Jaeger agent container configuration to point to the external
      collector. E.g.,
      ```
      args:
        - --reporter.grpc.host-port=external-jaeger-collector-host:14250
        - --reporter.type=grpc
      ```
1. Apply these changes to the cluster.

## Disable Jaeger entirely

To disable Jaeger entirely, do:

1. Update the Sourcegraph [site
   configuration](https://docs.sourcegraph.com/admin/config/site_config) to remove the
   `observability.tracing` field.
1. Remove the `base/jaeger` directory: `rm -rf base/jaeger`
1. Remove the jaeger agent containers from each `*.Deployment.yaml` and `*.StatefulSet.ayml` file.
1. Apply these changes to the cluster.

## Upgrading from 3.14 and earlier to 3.15 or later

The Kubernetes distribution of Sourcegraph 3.15 changed the standard way that Jaeger is deployed
inside the Sourcegraph cluster.

If you were previously using the [Jaeger
Operator](https://github.com/jaegertracing/jaeger-operator), do:

1. Delete the Jaeger instance: `kubectl delete jaeger jaeger`.
1. [Delete the Jaeger Operator](https://www.jaegertracing.io/docs/1.16/operator/#uninstalling-the-operator)
1. Merge the new version of this repository into your fork and apply the update. The new Jaeger
   components should be created automatically.

If you were previously connecting to an external Jaeger instance, do:

1. Merge the new version of this repository into your fork. Resolve any conflicts in files that
   contain configuration for the Jaeger agent to ensure the agent still points to the external
   Jaeger collector.
1. Remove the `base/jaeger` directory: `rm -rf base/jaeger`
1. Apply these changes to the cluster.

If you were previously not using Jaeger and would like to continue not using Jaeger, follow the
directions above to disable Jaeger entirely.
