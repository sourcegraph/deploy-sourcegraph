# Release

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
