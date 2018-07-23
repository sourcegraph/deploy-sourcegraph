#!/bin/bash

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
    // nick snyder
    // Publicly accessible URL to web app (e.g., what you type into your browser).
    "appURL": "http://localhost:3080",

    // The authentication provider to use for identifying and signing in users. Only one entry is supported.
    //
    // The builtin auth provider with signup disallowed (shown below) means that after the initial site admin signs in, all other users must be invited.
    //
    // Other providers are documented here:
    // https://about.sourcegraph.com/docs/config/site#authproviders-array
    "auth.providers": [{"type": "builtin", "allowSignup": false}],
}
EOM
./configure/config-file.sh

# For example, enable the Go and TypeScript language servers.
LANGUAGE_SERVERS=go,java \
EXPERIMENTAL_LANGUAGE_SERVERS= \
./configure/xlang/xlang.py

echo "> Generated yaml in $BASEDIR"

echo "Deploying..."

kubectl apply --prune -l deploy=sourcegraph -f $BASEDIR --recursive