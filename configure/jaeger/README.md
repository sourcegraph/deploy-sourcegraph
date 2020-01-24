# Jaeger

[Jaeger](https://github.com/jaegertracing/jaeger) is an open-source request tracing system that can
run inside of your Kubernetes cluster. Sourcegraph can connect to Jaeger to provide real-time
request traces that are useful for diagnosing performance issues and prescribing the appropriate
remedy (typically scaling up one of the services). If you are experiencing performance issues with
Sourcegraph, anticipate a high volume of traffic, or have a large amount of code, we recommend
connecting Sourcegraph to a Jaeger instance.

nThere are two options for connecting Sourcegraph to Jaeger:

* [Deploy-a-new-Jaeger-instance-inside-the-Sourcegraph-cluster](#Deploying-a-new-Jaeger-instance-alongside-Sourcegraph)
* [Connect to an existing Jaeger instance](#Connecting-Sourcegraph-to-an-existing-Jaeger-instance)

If you are unsure of what to do, we recommend deploying a new Jaeger instance inside the Sourcegraph
cluster.

## Deploying a new Jaeger instance alongside Sourcegraph

1. [Install the Jaeger
   Operator](https://www.jaegertracing.io/docs/1.16/operator/#installing-the-operator-on-kubernetes)
   in the Kubernetes cluster.

1. Deploy Jaeger using the [AllInOne
   strategy](https://www.jaegertracing.io/docs/1.16/operator/#quick-start-deploying-the-allinone-image).<br/>
   You can optionally choose one of the other strategies (e.g., Production, Streaming). In our
   experience, most use cases of Jaeger with Sourcegraph are for live-debugging purposes, so the
   AllInOne strategy (which stores traces in-memory) should suffice and is easiest to deploy.

1. Add the annotation `sidecar.jaegertracing.io/inject: "true"` to inject the Jaeger Agent sidecar
   containers into the relevant pods. You can use the following script:

   ```bash
   COLLECTOR_PATCH=$(echo 'sidecar.jaegertracing.io/inject: "true"' | yj)

   COLLECTOR_DEPLOYMENTS=(
       "github-proxy/github-proxy.Deployment.yaml"
       "query-runner/query-runner.Deployment.yaml"
       "repo-updater/repo-updater.Deployment.yaml"
       "searcher/searcher.Deployment.yaml"
       "replacer/replacer.Deployment.yaml"
       "frontend/sourcegraph-frontend.Deployment.yaml"
       "symbols/symbols.Deployment.yaml"
       "gitserver/gitserver.StatefulSet.yaml"
   )

   for FILE in "${COLLECTOR_DEPLOYMENTS[@]}"; do
       F="base/$FILE"
       cat $F | yj | jq ".metadata.annotations += $COLLECTOR_PATCH" | jy -o $F
   done
   ```

   Then apply the changes to the cluster:
   ```bash
   ./kubectl-apply-all.sh
   ```

   Verify the sidecar container has been injected into the frontend pod by running `kubectl get
   deploy sourcegraph-frontend -o=yaml` and checking for a container with image
   `jaegertracing/jaeger-agent`. Run the same command for the other deployments.

1. Update Sourcegraph site configuration to contain `"useJaeger": true`. Restart the frontend
   pods by deleting them: `kubectl delete pods --selector=app=sourcegraph-frontend`.

1. Run `kubectl port-forward svc/simplest-query 16686` and navigate to http://localhost:16686 in
   your browser. Verify you see traces for `frontend` and other Sourcegraph components.



## Connecting Sourcegraph to an existing Jaeger instance

To connect Sourcegraph to an existing Jaeger instance, you'll need to inject the appropriate Jaeger
Agent sidecar container into the relevant Sourcegraph deployments. The configuration will vary
depending on your version of Jaeger and where it is deployed, but the YAML snippet should look
something like this:

```yaml
# You may need to customize the command field to point the Jaeger Agent at
# your Jaeger Collector service.
command:
- /go/bin/agent-linux
- --collector.host-port=jaeger-collector:14267
image: jaegertracing/jaeger-agent
name: jaeger-agent
resources:
  limits:
    cpu: 100m
    memory: 100Mi
  requests:
    cpu: 100m
    memory: 100Mi
```

This YAML snippet should be added to the following Sourcegraph deployment files:

```
github-proxy/github-proxy.Deployment.yaml
query-runner/query-runner.Deployment.yaml
repo-updater/repo-updater.Deployment.yaml
searcher/searcher.Deployment.yaml
replacer/replacer.Deployment.yaml
frontend/sourcegraph-frontend.Deployment.yaml
symbols/symbols.Deployment.yaml
gitserver/gitserver.StatefulSet.yaml
```

Finally, update Sourcegraph site configuration to contain `"useJaeger": true`. Restart the frontend
pods by deleting them to ensure the configuration change takes effect: `kubectl delete pods
--selector=app=sourcegraph-frontend`.

## Migrating from old Jaeger configuration

If you are using Sourcegraph 3.12 or earlier, you might have installed an older version of Jaeger as
prescribed by an earlier version of these docs. If you are upgrading to 3.13 or later, we recommend
updating Jaeger as the older version will be unsupported after Sourcegraph 3.14. To migrate, do the
following:

1. First, set `"useJaeger": false` in site config. This will prevent errors from appearing in the
   logs during the migration process.

1. Remove the Jaeger Agent sidecar containers from the Sourcegraph deployments to which it has been
   added. If you followed the previous version of these docs to add the sidecar containers, the
   following files should be modified:
   ```
   github-proxy/github-proxy.Deployment.yaml
   query-runner/query-runner.Deployment.yaml
   repo-updater/repo-updater.Deployment.yaml
   searcher/searcher.Deployment.yaml
   replacer/replacer.Deployment.yaml
   frontend/sourcegraph-frontend.Deployment.yaml
   symbols/symbols.Deployment.yaml
   gitserver/gitserver.StatefulSet.yaml
   ```

   In each file, remove the `jaeger-agent` container from the deployment configuration. Run
   `kubectl-apply-all.sh` afterward to update the cluster.

1. Remove the old Jaeger installation. (Note: this will delete all existing trace data.)

   ```bash
   kubectl delete svc jaeger-cassandra jaeger-collector jaeger-query
   kubectl delete deploy jaeger-cassandra jaeger-collector jaeger-query
   kubectl delete pvc jaeger
   ```

1. Follow the instructions in the section above to deploy a new Jaeger instance alongside
   Sourcegraph.
