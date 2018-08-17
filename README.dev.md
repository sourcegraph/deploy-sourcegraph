# Development

## Cutting a release

- Make the desired changes to this repository. Most commonly, this involves updating the Docker image versions in `*.Deployment.yaml` to match the tagged version you are releasing. For images like language servers, you should look at our
  [container registry](https://console.cloud.google.com/gcr/images/sourcegraph-dev?project=sourcegraph-dev) to see what the latest versions are.

- Open a PR and wait for buildkite to pass and for your changes to be approved, then merge and check out master.
- Test what is currently checked in to master by [installing](docs/install.md) Sourcegraph on fresh cluster.
- Run `./release.sh $VERSION`.
  - If this is a patch version to a previous major/minor version, use `LATEST=false ./release.sh $VERSION`.
  - If this is a release candidate, run `LATEST=false ./release {$VERSION}-pre${N}` where `N` starts
    at 0 and increments as you test/cut new versions.
- [Update the `latestReleaseDataCenterBuild` value in `sourcegraph/sourcegraph`](https://sourcegraph.sgdev.org/github.com/sourcegraph/sourcegraph/-/blob/cmd/server/README.md#5-notify-existing-instances-that-an-update-is-available)

See `./release.sh --help` for information on what the script does.
