// This logic is in a separate file so that it's easier to drive the integration tests.

const envVar = 'DEPLOY_SOURCEGRAPH_ROOT_STEP_1'

export const deploySourcegraphRoot = process.env[envVar]

if (!deploySourcegraphRoot) {
    throw new Error(`"${envVar}" env var not defined`)
}

