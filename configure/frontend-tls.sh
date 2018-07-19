#!/bin/bash
# Configures the certificate and private key to use for TLS on the frontend.

set -e

cd "$(dirname "${BASH_SOURCE[0]}")/.."

BASE=${BASE:-base}

if [ -z ${FRONTEND_TLS_CERTIFICATE_PATH+x} ]; then
    read -p "Frontend TLS certificate path [none]: " FRONTEND_TLS_CERTIFICATE_PATH
fi

if [ -z ${FRONTEND_TLS_PRIVATE_KEY_PATH+x} ]; then
    read -p "Frontend TLS private key path [none]: " FRONTEND_TLS_PRIVATE_KEY_PATH
fi

# Start clean
rm -f $BASE/tls.Secret.yaml
FE=$BASE/frontend/sourcegraph-frontend.Deployment.yaml
cat $FE | yj | jq '(.spec.template.spec.containers[] | select(.name == "frontend") | .env) |= del(.[] | select(.name == "TLS_CERT" or .name == "TLS_KEY"))' | jy -o $FE

if [ -n "$FRONTEND_TLS_CERTIFICATE_PATH" ] && [ -n "$FRONTEND_TLS_PRIVATE_KEY_PATH" ]; then
    CERT=$(cat $FRONTEND_TLS_CERTIFICATE_PATH | base64)
    PRIVATE_KEY=$(cat $FRONTEND_TLS_PRIVATE_KEY_PATH | base64)

    cat > $BASE/frontend/tls.Secret.yaml <<EOM
apiVersion: v1
data:
  cert: "$CERT"
  key: "$PRIVATE_KEY"
kind: Secret
metadata:
  name: tls
type: Opaque
EOM

    cat $FE | yj | jq '(.spec.template.spec.containers[] | select(.name == "frontend") | .env) += [{name: "TLS_CERT", valueFrom: {secretKeyRef: {key: "cert", name: "tls"}}}, {name: "TLS_KEY", valueFrom: {secretKeyRef: {key: "key", name: "tls"}}}]' | jy -o $FE
    echo "> TLS configured"
else
    echo "> TLS not configured"
fi