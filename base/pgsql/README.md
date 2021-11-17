## Important Notice

Segment's self-hosted version of Sourcegraph uses an [External RDS Service](https://docs.sourcegraph.com/admin/external_services/postgres#kubernetes) for
the `pgsql` database.

You can find the definition for that database in the [segmentio/terracode-tooling](https://github.com/segmentio/terracode-tooling) repository.

If you are upgrading the current version of Sourcegrpah and are running into git conflicts, it is safe to delete any `pgsql` files.
