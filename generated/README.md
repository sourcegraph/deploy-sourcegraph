# Generated cluster

This directory contains a script that generates a cluster from source manifests by applying a series of transformations.

## Requirements

- [jq](https://stedolan.github.io/jq/download/) >= 1.6
- [yq](https://github.com/mikefarah/yq) > 3.3.0
- [GNU Parallel](https://www.gnu.org/software/parallel/)

## Instructions

1. Modify `params.sh` to determine the source manifests and transformations used to generate the cluster.
1. Run `./generate.sh` to generate a cluster in a subdirectory, `generated-cluster`.
1. View the diff between the generated cluster base and the base source manifests: `./generated/diff.sh` (this ignores any additional sources added
   outside of `base`).
   - The `ORIGINAL_BASE` environment variable can be used to specify a different set of original base manifests for the comparison against the generated manifests.

In general, the transformation pipeline works like this:

```python
for filename in SOURCE_BASE:
   file_contents = read(filename)

   transformation_pipeline=[
      (transformationA, arg1A, arg2A) ,
      (transformationB, arg1B, arg2b) ,
      ...
      ]

   for (transformation_func, args...) in transformation_pipeline:
      file_contents = transformation_func(file_contents, ...args, filename)

   new_file_path=GENERATED_BASE + "/" + filename
   write(new_file_path, file_contents)

# ...

def transformationX(file_contents_from_std_in, ...args, filename):
   file_contents = file_contents_from_std_in

   if not is_matching_filename(filename, ...args):
      return file_contents

   # do file manipulations
   file_contents = do_something(file_contents, ...args)

   return file_contents
```
