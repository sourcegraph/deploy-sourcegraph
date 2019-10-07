import * as pulumi from '@pulumi/pulumi'

const config = new pulumi.Config()

export const buildCreator = config.require('buildCreator')
export const deploySourcegraphRoot = config.require('deploySourcegraphRoot')
export const gcpUsername = config.require('gcpUsername')
