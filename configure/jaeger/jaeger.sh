#!/bin/bash
# Configures Jaeger to run in the cluster.

set -e

cd "$(dirname "${BASH_SOURCE[0]}")/../.."

./configure/util/require-basedir.sh

if [ -z ${JAEGER_ENABLED+x} ]; then
    read -p "Enable Jaeger [yN]: " JAEGER_ENABLED
fi

COLLECTOR_DEPLOYMENTS=(
    "github-proxy/github-proxy.Deployment.yaml"
    "indexer/indexer.Deployment.yaml"
    "lsp-proxy/lsp-proxy.Deployment.yaml"
    "query-runner/query-runner.Deployment.yaml"
    "repo-updater/repo-updater.Deployment.yaml"
    "searcher/searcher.Deployment.yaml"
    "frontend/sourcegraph-frontend.Deployment.yaml"
    "symbols/symbols.Deployment.yaml"
)

# Start clean.
rm -rf $BASEDIR/jaeger
find $BASEDIR -name 'gitserver-*.Deployment.yaml' -exec sh -c "cat {} | yj | jq '.spec.template.spec.containers |= del(.[] | select(.name == \"jaeger-agent\"))' | jy -o {}" \;
find $BASEDIR -name 'xlang-go*.Deployment.yaml' -exec sh -c "cat {} | yj | jq '.spec.template.spec.containers |= del(.[] | select(.name == \"jaeger-agent\"))' | jy -o {}" \;
for FILE in "${COLLECTOR_DEPLOYMENTS[@]}"; do
    F="$BASEDIR/$FILE"
    cat $F | yj | jq '.spec.template.spec.containers |= del(.[] | select(.name == "jaeger-agent"))' | jy -o $F
done

if [ "$JAEGER_ENABLED" == "y" ]; then
    mkdir -p $BASEDIR/jaeger
    cp configure/jaeger/*.yaml $BASEDIR/jaeger/

    COLLECTOR_PATCH=$(yj <<EOM
command:
- /go/bin/agent-linux
- --collector.host-port=jaeger-collector:14267
image: docker.sourcegraph.com/jaeger-agent
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

    find $BASEDIR -name 'gitserver-*.Deployment.yaml' -exec sh -c "cat {} | yj | jq '.spec.template.spec.containers += [$COLLECTOR_PATCH]' | jy -o {}" \;
    for FILE in "${COLLECTOR_DEPLOYMENTS[@]}"; do
        F="$BASEDIR/$FILE"
        cat $F | yj | jq ".spec.template.spec.containers += [$COLLECTOR_PATCH]" | jy -o $F
    done

    echo
    echo '> Set `useJaeger: true` in your site config and follow the instructions:'
    echo "> https://about.sourcegraph.com/docs/config/site/#usejaeger-boolean"
    echo
    echo "> Jaeger configured"
else
    echo "> Jaeger not configured"
fi