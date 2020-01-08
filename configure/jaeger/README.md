# Jaeger

[Jaeger](https://github.com/jaegertracing/jaeger) is an open-source request tracing system that can run inside of your Kubernetes cluster.

1.  Append the `kubectl apply` command for the Jaeger resources to `kubectl-apply-all.sh`.

    ```bash
    echo kubectl apply --prune -l deploy=jaeger -f configure/jaeger --recursive >> kubectl-apply-all.sh
    ```

1.  Apply your changes to Jaeger to the cluster.

    ```bash
    ./kubectl-apply-all.sh
    ```

1.  Add the Jaeger collector agent to supported services.

    ```bash
    COLLECTOR_PATCH=$(yj <<EOM
    command:
    - /go/bin/agent-linux
    - --collector.host-port=jaeger-collector:14267
    image: sourcegraph/jaeger-agent@sha256:f0a6a150bb39487aadb10b04e44fdd09efb93e1a14d39b01d4f556a3b0503ea1
    name: jaeger-agent
    resources:
      limits:
        cpu: 100m
        memory: 100Mi
      requests:
        cpu: 100m
        memory: 100Mi
    EOM
    )

    COLLECTOR_DEPLOYMENTS=(
        "github-proxy/github-proxy.Deployment.yaml"
        "query-runner/query-runner.Deployment.yaml"
        "repo-updater/repo-updater.Deployment.yaml"
        "searcher/searcher.Deployment.yaml"
        "replacer/replacer.Deployment.yaml"
        "frontend/frontend.Deployment.yaml"
        "symbols/symbols.Deployment.yaml"
        "gitserver/gitserver.StatefulSet.yaml"
    )

    for FILE in "${COLLECTOR_DEPLOYMENTS[@]}"; do
        F="base/$FILE"
        cat $F | yj | jq ".spec.template.spec.containers += [$COLLECTOR_PATCH]" | jy -o $F
    done
    ```

1.  Set `useJaeger: true` in your site config and follow [the instructions](https://about.sourcegraph.com/docs/config/site/#usejaeger-boolean).
