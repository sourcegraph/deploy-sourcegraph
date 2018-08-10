# DELETE ME BEFORE MERGING PR

- [] `xlang-go` has the `SRC_GIT_SERVERS` environment variable, why? (need to keep this in sync with rest of template logic...)

- [] `cache-ssd` is there any special configuration that's missing?

- `lightstep` information comes from site config?: https://sourcegraph.com/github.com/sourcegraph/deploy-sourcegraph/-/blob/templates/_helpers.tpl#L48-55

- write documentation about writing security context? https://sourcegraph.com/github.com/sourcegraph/deploy-sourcegraph/-/blob/templates/_helpers.tpl#L285

- xlang-go `"collectConfigEnv"`, `"collectTracingEnv"`, `"collectRedisEnv"` [link](https://sourcegraph.com/github.com/sourcegraph/deploy-sourcegraph/-/blob/templates/xlang/go/xlang-go.Deployment.yaml#L6-8) - write documentation?

- xlang-go `"NO_GO_GET_DOMAINS"` [link](https://sourcegraph.com/github.com/sourcegraph/deploy-sourcegraph/-/blob/templates/xlang/go/xlang-go.Deployment.yaml#L9) - config map? communicate with front end?

- communicate that you have to manually copy environment variables to each deployment

- `xlang-java` - `"EXECUTE_GRADLE_ORIGINAL_ROOT_PATHS"`, `"PRIVATE_ARTIFACT_REPO_ID"`, `"PRIVATE_ARTIFACT_REPO_URL"`, `"PRIVATE_ARTIFACT_REPO_USERNAME"`, `"PRIVATE_ARTIFACT_REPO_PASSWORD"` are all generate from site configuration as env vars - config map? communicate with front end?

- how to communicate `loadSelector`?

- [`commonVolumeMounts/commonVolumes` is used all over the the place](https://sourcegraph.com/search?q=repo:%5Egithub%5C.com/sourcegraph/deploy-sourcegraph%24+commonVolumeMounts%7CcommonVolume) - why? do I need to do anything special for this

- `xlang-go`, `xlang-typescript` all have [`mountCacheVolume`](https://sourcegraph.com/search?q=repo:%5Egithub%5C.com/sourcegraph/deploy-sourcegraph%24+mountCacheVolume) that reads from the site config. Is this necessary? (another instance of needing to parse the site config)
