# DELETE ME BEFORE MERGING PR

## Not Completed

- write overview explaining that Data Center consists of the base deployment, and the rest are "addons" that you can configure separately

  - I think that this should replace everything in install.md

* find/write documentation for `LIGHTSTEP_INCLUDE_SENSITIVE`

* `find . -exec yj | jq | jy` example for redis

- write about configuring storage classes in the migration document

- file issue about changing namespace stuff about clusterrolebindings in master

* write about what actually comes in the base deployment, and any enhancements that you'd like to make from there

* think more about if we should have stubbed-out references in the actual deployment files to the customization guide - this could get messy the more that we add

* should we all the documentation in one doc, or should we have readmes in each folder

* why is the `/pod-tmp` suffix necessary for `cache-ssd`?

* is there any public documentation about `pod-tmp-gc`?

* according to https://kubernetes.io/docs/reference/access-authn-authz/rbac/, `ClusterRoleBindings` can't be `namespace`d since
  they apply to the cluster as a whole, why does `configure/ssd/ssd.sh` specify one?

* add `jq` script for SSD config?

* actually test the steps in the customization guide

* documentation about how to scale things without templates

* document upgrade process for customers using new pure yaml deployment strategy

* document migration process from previous version for existing users

## Completed

- [x] add a section about language servers that also links to specific language server instructions (e.g. environment variables for Java)

* [x] verify that language servers will still work without specifying the environment variables (notably the BG ones)

* [x] write about SSDs

* [x] write about configuring SSH

* [x] write customization info for the site settings config map

* [x] yaml example for lightstep tokens

* [x] write about configuring TLS

## Deprioritized

- write about prometheus

- write about jager

- investigate https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#mounted-configmaps-are-updated-automatically to see if people actually need to handle updating each deployment when updating the site config
