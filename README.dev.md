# Development

## Cutting a release

* Make your desired changes to this repository. You're likely looking for the docker images in [values.yaml](./values.yaml).
* Run `./generate.sh`.
* Open a PR and wait for buildkite to pass and for your changes to be approved, then merge and check out master.
* Run `./release.sh $VERSION`. If this is a release candidate, `$VERSION` should have the
  suffix `-rcN` where `N` starts at 0 and increments as you test/cut new versions.

See `./release.sh --help` for information on what the script does.

## Development tips

* Whitespace in Helm templates can be tricky. When embedding the contents of a helper template, use
  the form `{{- include "myHelper" $arg | nindent $indent }}`.
  * If the output of the helper template could be empty, use `{{- include "myHelper" $arg | nindent $indent | trimSuffix "\n " }}`, where the argument to `trimSuffix` has $indent spaces.
