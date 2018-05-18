# Development

## Release

Sourcegraph Datacenter uses semantic versioning. To cut a new release, push a Git tag with the version name to this
repository:

```
git tag x.y.z
git push origin x.y.z
```

If updating the "latest" version, run the following:

```
git tag -d latest
git tag latest
git push -f origin latest
```


## Development tips

* Whitespace in Helm templates can be tricky. When embedding the contents of a helper template, use
  the form `{{- include "myHelper" $arg | nindent $indent }}`.
  * If the output of the helper template could be empty, use `{{- include "myHelper" $arg | nindent
    $indent | trimSuffix "\n " }}`, where the argument to `trimSuffix` has $indent spaces.
