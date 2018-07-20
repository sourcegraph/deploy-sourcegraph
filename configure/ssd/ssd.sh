#!/bin/bash
# Configures nodes to use a locally mounted SSD.

set -e

cd "$(dirname "${BASH_SOURCE[0]}")/../.."

./configure/util/require-basedir.sh

if [ -z ${SSD_NODE_PATH+x} ]; then
    read -p "SSD node path (e.g. /mnt/disks/ssd0 on GCP) [none]: " SSD_NODE_PATH
fi

# Start clean
rm -rf $BASEDIR/ssd

if [ -n "$SSD_NODE_PATH" ]; then
    if [ -z ${KUBERNETES_NAMESPACE+x} ]; then
        read -p "Kubernetes namespace [none]: " KUBERNETES_NAMESPACE
    fi

    mkdir -p $BASEDIR/ssd
    cp configure/ssd/*.yaml $BASEDIR/ssd

    if [ -n "$KUBERNETES_NAMESPACE" ]; then
        CRB=$BASEDIR/ssd/pod-tmp-gc.ClusterRoleBinding.yaml
        cat $CRB | yj | jq "(.subjects[] | select(.name == \"pod-tmp-gc\")) |= (.namespace = \"$KUBERNETES_NAMESPACE\")" | jy -o $CRB
    fi

    DS=$BASEDIR/ssd/pod-tmp-gc.DaemonSet.yaml
    cat $DS | yj | jq ".spec.template.spec.volumes = [{name: \"pod-tmp\", hostPath: {path: \"$SSD_NODE_PATH/pod-tmp\"}}]" | jy -o $DS
    find $BASEDIR -name "*Deployment.yaml" -exec sh -c "cat {} | yj | jq '(.spec.template.spec.volumes | select(. != null) | .[] | select(.name == \"cache-ssd\")) |= (del(.emptyDir) + {hostPath: {path: \"$SSD_NODE_PATH/pod-tmp\"}})' | jy -o {}" \;

    echo "> SSDs configured"
else
    find $BASEDIR -name "*Deployment.yaml" -exec sh -c "cat {} | yj | jq '(.spec.template.spec.volumes | select(. != null) | .[] | select(.name == \"cache-ssd\")) |= (del(.hostPath) + {emptyDir: { }})' | jy -o {}" \;
    echo "> SSDs not configured"
fi
