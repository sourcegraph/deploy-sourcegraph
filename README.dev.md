# Development

## Cutting a release

- Make the desired changes to this repository. Most commonly, this involves updating the Docker image versions in `*.Deployment.yaml` to match the tagged version you are releasing. For images like language servers, you should look at our
  [container registry](https://console.cloud.google.com/gcr/images/sourcegraph-dev?project=sourcegraph-dev) to see what the latest versions are.

- Open a PR and wait for buildkite to pass and for your changes to be approved, then merge and check out master.
- Test what is currently checked in to master by [installing](docs/install.md) Sourcegraph on fresh cluster.
- Create a git tag and push it to the repository:

  ```bash
  VERSION = vX.Y.Z

  # If this is a release candidate: VERSION = `vX.Y.Z-pre${N}` (where `N` starts at 0 and increments as you test/cut new versions)

  # 🚨 Make sure that you have the commit that you want to tag as $VERSION checked out!

  git tag $VERSION
  git push origin $VERSION
  ```

- [Update the `latestReleaseDataCenterBuild` value in `sourcegraph/sourcegraph`](https://sourcegraph.sgdev.org/github.com/sourcegraph/sourcegraph/-/blob/cmd/server/README.md#5-notify-existing-instances-that-an-update-is-available)
