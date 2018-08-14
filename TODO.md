# DELETE ME BEFORE MERGING PR

- [x] `xlang-go` has the `SRC_GIT_SERVERS` environment variable, why? (need to keep this in sync with rest of template logic...)

  - there is no intermediate step -> just solve this https://github.com/sourcegraph/sourcegraph/issues/12804

* `lightstep` information comes from site config?: https://sourcegraph.com/github.com/sourcegraph/deploy-sourcegraph

  - for non-xlang services, can remove env var since it's read from the site config
  - the language servers need to figure out the configuration, intermediate thing is just to read from enviroment variables for now (long-term , use stand LSP configuration methods)
  - https://github.com/sourcegraph/sourcegraph/issues/12825

* write documentation about writing security context? https://sourcegraph.com/github.com/sourcegraph/deploy-sourcegraph/-/blob/templates/_helpers.tpl#L285

* xlang-go `"collectConfigEnv"`, `"collectTracingEnv"`, `"collectRedisEnv"` [link](https://sourcegraph.com/github.com/sourcegraph/deploy-sourcegraph/-/blob/templates/xlang/go/xlang-go.Deployment.yaml#L6-8) - write documentation?

  - config: remove need to have directly mounted config file
  - tracing: see lightsep above
  - redis, document that these environment variables are available
  - https://github.com/sourcegraph/sourcegraph/issues/12827
  - https://github.com/sourcegraph/sourcegraph/issues/12828

* xlang-go `"NO_GO_GET_DOMAINS"` [link](https://sourcegraph.com/github.com/sourcegraph/deploy-sourcegraph/-/blob/templates/xlang/go/xlang-go.Deployment.yaml#L9) - config map? communicate with front end?

  - `go-langserver` seems to read this both from the site configuration directly, and the environment variable seems to be totally ignored
  - the deployment DOES need to mount the site config as a config map, which is annoying
  - we should remove the need for the site config, and actually pass an environment variable that has an effect
  - ultimately, both xlang-go and xlang-java should get configuration values dynamically over standard LSP methods (future)
  - https://github.com/sourcegraph/sourcegraph/issues/12827

* communicate that you have to manually copy environment variables to each deployment

* [x] `xlang-java` - `"EXECUTE_GRADLE_ORIGINAL_ROOT_PATHS"`, `"PRIVATE_ARTIFACT_REPO_ID"`, `"PRIVATE_ARTIFACT_REPO_URL"`, `"PRIVATE_ARTIFACT_REPO_USERNAME"`, `"PRIVATE_ARTIFACT_REPO_PASSWORD"` are all generate from site configuration as env vars - config map? communicate with front end?

  - these values aren't actually a part of the site config, they're only used to set env vars
    for the java language server in data center (these have no effect on server)
  - deprecate the site config for those var names
  - document the fact that these environment variables exist for xlang-java's deployment
  - cc @slimsag
  - https://github.com/sourcegraph/sourcegraph/issues/12810

* [x] how to communicate `nodeSelector`?

  - https://github.com/sourcegraph/sourcegraph/issues/12806
  - document this in the readme, but this is standard k8s

- [x] [`commonVolumeMounts/commonVolumes` is used all over the the place](https://sourcegraph.com/search?q=repo:%5Egithub%5C.com/sourcegraph/deploy-sourcegraph%24+commonVolumeMounts%7CcommonVolume) - why? do I need to do anything special for this

  - write documentation saying how to add these manually if you need them
  - cc @beyang
  - issue https://github.com/sourcegraph/sourcegraph/issues/12805

- [x] `xlang-go`, `xlang-typescript` all have [`mountCacheVolume`](https://sourcegraph.com/search?q=repo:%5Egithub%5C.com/sourcegraph/deploy-sourcegraph%24+mountCacheVolume) that reads from the site config. Is this necessary? (another instance of needing to parse the site config)

  - https://github.com/sourcegraph/sourcegraph/issues/12809
  - https://github.com/sourcegraph/sourcegraph/issues/12807

  - you don't actually need to have this in the site config, just document that you can specify what the `hostPath` and `cache-ssd` volumes point to if you need higher performance

* if we are releasing the raw yaml, then we need to handle modifying the site configuration and updating the config map hashes, etc.
