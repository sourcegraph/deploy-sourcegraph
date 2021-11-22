## Important Notice

Segment's self-hosted version of Sourcegraph uses an [External S3 Bucket](https://docs.sourcegraph.com/admin/external_services/object_storage) for blob storage.

You can find the definition for that S3 bucket in the [segmentio/terracode-tooling](https://github.com/segmentio/terracode-tooling/blob/d3b8288785a64d807f08cec59232901e65d94c9c/stage/us-west-2/sourcegraph/s3.tf) repository.

If you are upgrading the current version of Sourcegraph and are running into git conflicts, it is safe to delete any `minio` files.
