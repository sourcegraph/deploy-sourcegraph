import * as gcp from '@pulumi/gcp'
import * as k8s from '@pulumi/kubernetes'
import * as pulumi from '@pulumi/pulumi'

import { paramCase } from 'change-case'

import { buildCreator } from './config'

const name = `ds-integ-fresh-test`
const location = gcp.config.zone

const gkeVersion = gcp.container.getEngineVersions({
    location,
    versionPrefix: '1.14',
}).latestNodeVersion

const cluster = new gcp.container.Cluster(`${name}-cluster`, {
    description: 'Scratch cluster used for testing sourcegraph/deploy-sourcegraph',

    location,
    project: gcp.config.project,

    minMasterVersion: gkeVersion,
    nodeVersion: gkeVersion,
    initialNodeCount: 3,

    nodeConfig: {
        diskType: 'pd-ssd',
        machineType: 'n1-standard-16',

        oauthScopes: [
            'https://www.googleapis.com/auth/compute',
            'https://www.googleapis.com/auth/devstorage.read_only',
            'https://www.googleapis.com/auth/logging.write',
            'https://www.googleapis.com/auth/monitoring',
        ],
    },

    resourceLabels: {
        'cost-category': 'build',
        repository: 'deploy-sourcegraph',
        'integration-test': 'fresh',
        creator: paramCase(buildCreator),
    },
})

const clusterContext = pulumi
    .all([cluster.name, cluster.zone, cluster.project])
    .apply(([name, zone, project]) => `gke_${project}_${zone}_${name}`)

export const kubeconfig = pulumi
    .all([clusterContext, cluster.endpoint, cluster.masterAuth])
    .apply(([context, endpoint, masterAuth]) => {
        return `apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${masterAuth.clusterCaCertificate}
    server: https://${endpoint}
  name: ${context}
contexts:
- context:
    cluster: ${context}
    user: ${context}
  name: ${context}
current-context: ${context}
kind: Config
preferences: {}
users:
- name: ${context}
  user:
    auth-provider:
      config:
        cmd-args: config config-helper --format=json
        cmd-path: gcloud
        expiry-key: '{.credential.token_expiry}'
        token-key: '{.credential.access_token}'
      name: gcp
`
    })

export const k8sProvider = new k8s.Provider(`${name}-provider`, {
    kubeconfig,
})

export const clusterName = cluster.name
