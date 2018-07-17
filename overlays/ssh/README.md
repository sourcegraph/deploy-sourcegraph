# SSH

This overlay configures Sourcegraph to access your git host using SSH keys.

## Usage

This overlay depends on the existance of a secret named `gitserver-ssh`. To create and manage this secret, you should create your own overlay that defines this secret:

```yaml
# gitserver-ssh.Secret.yaml
apiVersion: v1
data:
  id_rsa: "" # TODO(you): base64 encoded private key
  known_hosts: "" # TODO(you): base64 encoded known_hosts
kind: Secret
metadata:
  name: gitserver-ssh
type: Opaque
```

If have configured more than one gitserver, then you will need to copy `gitserver-1` to create `gitserver-n` for each of your `n` gitservers in your overlay.

Update `SRC_GIT_SERVERS` to be a space separated list of gitserver addresses.
