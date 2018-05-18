# Development

## Release

See `./release.sh --help`.

## Development tips

* Whitespace in Helm templates can be tricky. When embedding the contents of a helper template, use
  the form `{{- include "myHelper" $arg | nindent $indent }}`.
  * If the output of the helper template could be empty, use `{{- include "myHelper" $arg | nindent
    $indent | trimSuffix "\n " }}`, where the argument to `trimSuffix` has $indent spaces.
