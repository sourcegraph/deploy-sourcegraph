# Transport Layer Security (TLS)

This overlay enables Transport Layer Security (TLS) for Sourcegraph so you can access your Sourcegraph instance over HTTPS.

## Usage

This overlay depends on the existance of a secret named `tls`. To create and manage this secret, you should create your own overlay that defines this secret:

```yaml
# tls.Secret.yaml
apiVersion: v1
data:
  cert: "" # TODO(you): base64 encoded certificate
  key: "" # TODO(you): base64 encoded private key
kind: Secret
metadata:
  name: tls
type: Opaque
```
