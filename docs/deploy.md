# Deploy process

This document describes recommended practices for deploying Sourcegraph and managing your yaml.

## Storing your yaml

While you can directly apply the yaml in `base/` to a Kubernetes cluster to get a working Sourcegraph instance,
you will ultimately want to customize the yaml to suit your needs.

We recommend creating a script that idempotently generates your customized yaml, like this:

```bash
#!/bin/bash

git clone https://github.com/sourcegraph/deploy-sourcegraph.git
cd deploy-sourcegraph

# Pin to a specific version of the base configuration.
# Change this when you want to upgrade to a newer version of Sourcegraph.
git checkout $REF

# Generated yaml is stored in this directory.
# This environment variable required by scripts in ./configure/
export BASEDIR=generated

# Copy the base yaml to the generated directory.
rm -rf $BASEDIR/*
mkdir -p $BASEDIR
cp -r base/* $BASEDIR/

# Run your desired configuration scripts.

## For example, apply a custom site config.
## You should probaby store your site config in a separate file and
## not embed your site config in the deploy script like this (this is just an illustrative example).
## SITE_CONFIG_PATH is exported because other configuration scripts (e.g. xlang.py) also run ./configure/config-file.sh.
export SITE_CONFIG_PATH=/tmp/config.json
cat > $SITE_CONFIG_PATH <<EOM
{
    "appURL": "http://sourcegraph.example.com:3080",
}
EOM
./configure/config-file.sh

# For example, enable the Go and TypeScript language servers.
LANGUAGE_SERVERS=go,typescript \
EXPERIMENTAL_LANGUAGE_SERVERS= \
./configure/xlang/xlang.py

echo "> Generated yaml in $BASEDIR"
```

You might want to check in the generated yaml to source control so you can inspect the diff when upgrading.

## Deploying generated yaml

Once you have your generated yaml, you can deploy it to a Kubernetes cluster with a single command:

```bash
kubectl apply --prune -l deploy=sourcegraph -f $BASEDIR --recursive
```

Notes:

- This command assumes that all Sourcegraph services have the label `deploy: sourcegraph` (which is true for all the yaml we provide).
  If you add your own services and want to manage them with this process, ensure they have that label.
- `--prune` deletes any existing resources that have the label `deploy: sourcegraph` and are not present in `$BASEDIR`.
  When using `--prune` you must provide ALL of the yaml in `$BASEDIR`, not just a single file or subdirectory of `$BASEDIR`.

## Rolling back

Rolling back is conceptually as simple as applying the previous version of the yaml.

1.

If you are using version control to store the state of your generated yaml, then a rollback should be as simple as checking out the old yaml
and deploying it to your cluster as documented above.

At the very least, your deploy script should be checked in so you can check out the previous version of the deploy script,
generate
