# `xlang-java[-bg]` Customization

The `xlang-java` and `xlang-java-bg` deployments support the following environment variables:

## `EXECUTE_GRADLE_ORIGINAL_ROOT_PATHS` (string)

A comma-delimited list of patterns that selects repository revisions for which to execute Gradle scripts,rather than extracting Gradle metadata statically.

**Security note**: these should be restricted to repositories within your own organization.

A percent sign (`%`) can be used to prefix-match. For example, `git://my.internal.host/org1/%,git://my.internal.host/org2/repoA?%` would select all revisions of all repositories in `org1` and all revisions of `repoA` in `org2`.

Note: this field is misnamed, as it matches against the `originalRootURI` LSP initialize parameter, rather than the no-longer-used `originalRootPath` parameter.

## `PRIVATE_ARTIFACT_REPO_ID` (string)

Private artifact repository ID in your build files. If you do not explicitly include the private artifact repository, then set this to some unique string (e.g,. `my-repository`).

## `PRIVATE_ARTIFACT_REPO_URL` (string)

The URL that corresponds to `PRIVATE_ARTIFACT_REPO_ID` (e.g., `http://my.artifactory.local/artifactory/root`).

## `PRIVATE_ARTIFACT_REPO_USERNAME` (string)

The username to authenticate to the private Artifactory.

## PRIVATE_ARTIFACT_REPO_PASSWORD (string)

The password to authenticate to the private Artifactory.
