#!/bin/bash
# This configures gitserver to clone repos with a SSH key.

set -e

cd "$(dirname "${BASH_SOURCE[0]}")/.."

./configure/util/require-basedir.sh

if [ -z ${GITSERVER_SSH_PRIVATE_KEY_PATH+x} ]; then
    read -p "SSH private key path (e.g. ~/.ssh/id_rsa): " GITSERVER_SSH_PRIVATE_KEY_PATH
fi

if [ -z ${GITSERVER_SSH_KNOWN_HOSTS_PATH+x} ]; then
    read -p "SSH known hosts path (e.g. ~/.ssh/known_hosts): " GITSERVER_SSH_KNOWN_HOSTS_PATH
fi

# Clean any existing ssh volumes.
find $BASEDIR -name 'gitserver-*.Deployment.yaml' -exec sh -c "cat {} | yj | jq '(.spec.template.spec.containers[].volumeMounts | select(length > 0)) |= del(.[]? | select(.name == \"ssh\"))' | jy -o {}" \;
find $BASEDIR -name 'gitserver-*.Deployment.yaml' -exec sh -c "cat {} | yj | jq '.spec.template.spec.volumes |= del(.[] | select(.name == \"ssh\"))' | jy -o {}" \;

if [ -n "$GITSERVER_SSH_PRIVATE_KEY_PATH" ] && [ -n "$GITSERVER_SSH_KNOWN_HOSTS_PATH" ]; then
    PRIVATE_KEY=$(cat $GITSERVER_SSH_PRIVATE_KEY_PATH | base64)
    KNOWN_HOSTS=$(cat $GITSERVER_SSH_KNOWN_HOSTS_PATH | base64)

    cat > $BASEDIR/gitserver/gitserver-ssh.Secret.yaml <<EOM
apiVersion: v1
data:
  id_rsa: "$PRIVATE_KEY"
  known_hosts: "$KNOWN_HOSTS"
kind: Secret
metadata:
  name: gitserver-ssh
type: Opaque
EOM

    # TODO(jq 1.6): This should only attach the ssh volume to the gitserver container, in case there are other containers.
    # Unfortunately there is a bug in jq 1.5 (that is fixed in master by unreleased) that prevents the obvious way to accomplish this from working:
    # https://github.com/stedolan/jq/issues/1146
    # find $BASEDIR -name 'gitserver-*.Deployment.yaml' -exec sh -c "cat {} | yj | jq '(.spec.template.spec.containers[] | select(.name | startswith(\"gitserver-\")).volumeMounts) += [{mountPath: \"/root/.ssh\", name: \"ssh\"}]' | jy -o {}" \;
    # Instead, just attach the .ssh volume to all containers running in gitserver.
    find $BASEDIR -name 'gitserver-*.Deployment.yaml' -exec sh -c "cat {} | yj | jq '.spec.template.spec.containers[].volumeMounts += [{mountPath: \"/root/.ssh\", name: \"ssh\"}]' | jy -o {}" \;
    find $BASEDIR -name 'gitserver-*.Deployment.yaml' -exec sh -c "cat {} | yj | jq '.spec.template.spec.volumes += [{name: \"ssh\", secret: {defaultMode: 384, secretName:\"gitserver-ssh\"}}]' | jy -o {}" \;
    echo "> SSH configured"
else
    rm -f $BASEDIR/gitserver/gitserver-ssh.Secret.yaml
    echo "> SSH not configured"
fi
