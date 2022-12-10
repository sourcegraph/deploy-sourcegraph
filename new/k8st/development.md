# Examples

Run `EXAMPLE=default yarn generate-example` to regenerate the default manifest, or substitute another subdirectory of `examples/` for the value of `EXAMPLE`.

If you are comparing against another k8s manifest that wasn't generated using this method (e.g., one hand-modified by a customer), you can use `NORMALIZE=${DIRECTORY} yarn normalize` to normalize it so you can diff it (`diff -ru one two`).