#!/bin/bash
# Configures the number of gitserver replicas.

set -e

cd "$(dirname "${BASH_SOURCE[0]}")/.."

BASE=${BASE:-base}

if [ -z ${GITSERVER_REPLICA_COUNT+x} ]; then
    read -p "Number of gitservers [1]: " GITSERVER_REPLICA_COUNT
fi

if [ -z "$GITSERVER_REPLICA_COUNT" ]; then
    GITSERVER_REPLICA_COUNT=1
fi

# Cleanup previous replicas.
GITSERVER_BASE=$BASE/gitserver
GITSERVER_TMP=$GITSERVER_BASE/tmp
mkdir -p $GITSERVER_TMP
mv $GITSERVER_BASE/gitserver-1.*.yaml $GITSERVER_TMP
rm -f $GITSERVER_BASE/gitserver-*.yaml
mv $GITSERVER_TMP/* $GITSERVER_BASE
rm -rf $GITSERVER_TMP

# Define the additional replicas.
GITSERVERS=gitserver-1:3178
for i in $(seq 1 $GITSERVER_REPLICA_COUNT); do
    if [ "$i" != "1" ]; then
        cp $GITSERVER_BASE/gitserver-1.Deployment.yaml $GITSERVER_BASE/gitserver-$i.Deployment.yaml
        cp $GITSERVER_BASE/gitserver-1.PersistentVolumeClaim.yaml $GITSERVER_BASE/gitserver-$i.PersistentVolumeClaim.yaml
        cp $GITSERVER_BASE/gitserver-1.Service.yaml $GITSERVER_BASE/gitserver-$i.Service.yaml

        sed -i.seibak -e "s/gitserver-1/gitserver-$i/g" $GITSERVER_BASE/gitserver-$i.Deployment.yaml
        sed -i.seibak -e "s/gitserver-1/gitserver-$i/g" $GITSERVER_BASE/gitserver-$i.PersistentVolumeClaim.yaml
        sed -i.seibak -e "s/gitserver-1/gitserver-$i/g" $GITSERVER_BASE/gitserver-$i.Service.yaml

        rm -rf $GITSERVER_BASE/*.seibak

        GITSERVERS="$GITSERVERS gitserver-$i:3178"
    fi
done

# Update SRC_GIT_SERVERS to contain all replicas.
find $BASE -name '*.Deployment.yaml' -exec sh -c "cat {} | yj | jq '(.spec.template.spec.containers[] | .env | select(. != null) | .[] | select(.name == \"SRC_GIT_SERVERS\")) |= (.value = \"$GITSERVERS\")' | jy -o {}" \;

echo "> gitservers configured: $GITSERVER_REPLICA_COUNT"
