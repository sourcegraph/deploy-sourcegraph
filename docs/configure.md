# Configuring your deployment

This document describes a few common ways to configure your Sourcegraph deployment.

## Add language servers for code intelligence

> Code intelligence is a [paid upgrade](https://about.sourcegraph.com/pricing/) on top of the Data
> Center deployment option. After following these instructions to confirm it
> works, [buy code intelligence](https://about.sourcegraph.com/contact/sales).

[Code intelligence](https://about.sourcegraph.com/docs/code-intelligence) provides advanced code
navigation and cross-references for your code on Sourcegraph.

To enable code intelligence:

1.  Run `./configure/xlang/xlang.py` and follow the prompts to select which languages to enable.
1.  [Apply the updated yaml to your cluster](deploy.md)

For more information,

- See the [language-specific docs](https://about.sourcegraph.com/docs/code-intelligence) for
  configuring specific languages.
- [Contact us](mailto:support@sourcegraph.com) with questions or problems relating to code
  intelligence.

## Site config

The site configuration is stored in `config-file.ConfigMap.yaml`. For the full list of options, see [Sourcegraph site configuration options](https://about.sourcegraph.com/docs/config/site).

To change you site config:

1.  Edit `config-file.ConfigMap.yaml`.
1.  Run `./configure/config-file.sh`. A hash of the site config is appended to the name so that all pods restart to load the new configuration.
1.  [Apply the updated yaml to your cluster](deploy.md)

## Authentication
