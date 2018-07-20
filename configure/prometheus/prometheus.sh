#!/bin/bash
# Configure Prometheus to run in the cluster.

set -e

cd "$(dirname "${BASH_SOURCE[0]}")/../.."

BASE=${BASE:-base}

if [ -z ${PROMETHEUS_ENABLED+x} ]; then
    read -p "Enable Prometheus [yN]: " PROMETHEUS_ENABLED

    if [ -z ${KUBERNETES_NAMESPACE+x} ]; then
        read -p "Kubernetes namespace [none]: " KUBERNETES_NAMESPACE
    fi

    if [ "$PROMETHEUS_ENABLED" == "y" ]; then
        if [ -z ${PROMETHEUS_EXTRA_RULES_PATH+x} ]; then
            read -p "Path to extra Prometheus rules [none]: " PROMETHEUS_EXTRA_RULES_PATH
        fi

        if [ -z ${ALERT_MANAGER_CONFIG_PATH+x} ]; then
            read -p "Alert manager config path [none]: " ALERT_MANAGER_CONFIG_PATH
        fi

        if [ -z ${ALERT_MANAGER_URL+x} ]; then
            read -p "Alert manager url [none]: " ALERT_MANAGER_URL
        fi
    fi
fi

# Start clean.
rm -rf $BASE/prometheus

if [ "$PROMETHEUS_ENABLED" == "y" ]; then
    mkdir -p $BASE/prometheus
    cp configure/prometheus/*.yaml $BASE/prometheus

    if [ -n "$KUBERNETES_NAMESPACE" ]; then
        CRB=$BASE/prometheus/prometheus.ClusterRoleBinding.yaml
        cat $CRB | yj | jq "(.subjects[] | select(.name == \"prometheus\")) |= (.namespace = \"$KUBERNETES_NAMESPACE\")" | jy -o $CRB
    fi

    if [ -n "$PROMETHEUS_EXTRA_RULES_PATH" ]; then
        # Defensively escape all backslashes and double quotes.
        EXTRA_RULES=$(cat $PROMETHEUS_EXTRA_RULES_PATH | ./configure/util/sanitize.sh)

        # Concat the environment variable instead of embedding since the file contents
        # might contain charaters that could be interpreted by the shell (e.g. $).
        JQARG=".data.\"extra.rules\" = \"""$EXTRA_RULES""\""

        PCM=$BASE/prometheus/prometheus.ConfigMap.yaml
        cat $PCM | yj | jq "$JQARG" | jy -o $PCM
    fi

    if [ -n "$ALERT_MANAGER_CONFIG_PATH" ] && [ -n "$ALERT_MANAGER_URL" ]; then
        mkdir -p $BASE/prometheus/alertmanager
        cp configure/prometheus/alertmanager/*.yaml $BASE/prometheus/alertmanager/

        # Defensively escape all backslashes and double quotes.
        ALERT_MANAGER_CONFIG=$(cat $ALERT_MANAGER_CONFIG_PATH | ./configure/util/sanitize.sh)

        # Concat the environment variable instead of embedding since the file contents
        # might contain charaters that could be interpreted by the shell (e.g. $).
        JQARG=".data.\"config.yml\" = \"""$ALERT_MANAGER_CONFIG""\""
        
        ACM=$BASE/prometheus/alertmanager/alertmanager.ConfigMap.yaml
        cat $ACM | yj | jq "$JQARG" | jy -o $ACM

        AD=$BASE/prometheus/alertmanager/alertmanager.Deployment.yaml
        cat $AD | yj | jq "(.spec.template.spec.containers[] | select(.name == \"alertmanager\") | .args) |= (. + [\"-web.external-url=$ALERT_MANAGER_URL\"] | unique)" | jy -o $AD

        PD=$BASE/prometheus/prometheus.Deployment.yaml
        cat $PD | yj | jq "(.spec.template.spec.containers[] | select(.name == \"prometheus\") | .args) |= (. + [\"-web.external-url=$ALERT_MANAGER_URL\"] | unique)" | jy -o $PD

        echo "> Alert manager configured"
    else
        echo "> Alert manager not configured"
    fi
    echo "> Prometheus configured"
else
    echo "> Prometheus not configured"
fi