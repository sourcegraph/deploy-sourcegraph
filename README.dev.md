# Development

## Cutting a release

- Make the desired changes to this repository. Most commonly, this involves updating the Docker image versions in `values.yaml` to match the tagged version you are releasing.
- Run `./generate.sh`.
- Open a PR and wait for buildkite to pass and for your changes to be approved, then merge and check out master.
- Test this release on a fresh cluster before cutting a real release. Cut a test release (`LATEST=false ./release $TEST_VERSION`), then use the instructions [this installation doc](docs/install.md) to set up a new cluster. (Make sure that you use the helm charts located at https://github.com/sourcegraph/datacenter/archive/$TEST_VERSION.tar.gz).
- Run `./release.sh $VERSION`.
  - If this is a patch version to a previous major/minor version, use `LATEST=false ./release.sh $VERSION`.
  - If this is a release candidate, run `LATEST=false ./release {$VERSION}-pre${N}` where `N` starts
    at 0 and increments as you test/cut new versions.

See `./release.sh --help` for information on what the script does.

## Development tips

- Whitespace in Helm templates can be tricky. When embedding the contents of a helper template, use
  the form `{{- include "myHelper" $arg | nindent $indent }}`.
  - If the output of the helper template could be empty, use `{{- include "myHelper" $arg | nindent $indent | trimSuffix "\n " }}`, where the argument to `trimSuffix` has $indent spaces.
