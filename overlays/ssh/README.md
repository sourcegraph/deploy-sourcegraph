# SSH

This overlay configures Sourcegraph to access your git host using SSH keys.

1.  Store the base64 encoded private key and known hosts file in the `gitserver-ssh` secret.
2.  Configure all gitserver containers to mount the secret to `/root/.ssh` (the example in this directory assumes one gitserver).
