# Migrating from Data Center 2.9.x

## The old way

The 2.9.x series was deployed by configuring `values.yaml` and using `helm` to generate the final yaml to deploy to a cluster.

There were a few problems with this approach:

- All configuration had to flow through our templates, which made it harder for our customers to make small adjustements on their own.
- Writing Go templates inside of yaml was error prone and hard to maintain. It was too easy to make a silly mistake and generate invalid yaml. Our editors could not help us because Go template logic made the yaml templates not valid yaml.
- It required using `helm` to generate templates even though we have customers who don't care to use `helm` to deploy the yaml.
- Customers who did want to use `helm` had to run `tiller` in their cluster and set up appropriate permissions.

## The new way

Our new approach is simpler and more flexible.

- We have removed our dependency on `helm`. It is no longer needed to generate templates, and we no longer recommend it as the easiest way to deploy our yaml to a cluster.
- Our base config is pure yaml which can be deployed directly to a cluster. It is also easier for us to maintain.
- For convenience, we provide configuration scripts for common customizations of our base yaml. The scripts are yaml-in-yaml-out. This means it is easy for our customers to write their own scripts for further customizations.

## Migrating

TODO(nick)
