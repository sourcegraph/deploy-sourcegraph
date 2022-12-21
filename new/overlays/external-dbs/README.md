# Kustomize Overlay - External Databases

This overlay allows you to replace the default postgres database with an external postgres database.

See our [official docs on using external PostgreSQL server](https://docs.sourcegraph.com/admin/external_services/postgres) for more details.

## Important Notes

**Do not** point both the `main PostgreSQL database` (pgsql-db) and the `PostgreSQL database for Code Intel` (codeintel-db) to the same database or your Sourcegraph instance will refuse to start.

## General recommendations

If you choose to set up your own PostgreSQL server, please note we strongly recommend each database to be set up in different servers and/or hosts.
