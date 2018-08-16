# DELETE ME BEFORE MERGING PR

## Not Completed

- write overview explaining that Data Center consists of the base deployment, and the rest are "addons" that you can configure separately

  - I think that this should replace everything in install.md

- verify that language servers will still work without specifying the environment variables (notably the BG ones)

- investigate https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#mounted-configmaps-are-updated-automatically to see if people actually need to handle updating each deployment when updating the site config

- find/write documentation for `LIGHTSTEP_INCLUDE_SENSITIVE`

- `find . -exec yj | jq | jy` example for redis

- add a section about language servers that also links to specific language server instructions (e.g. environment variables for Java)

- write about configuring SSH

- write about configuring storage classes

- write about SSDs

- write about prometheus

- write about jager

- write about what actually comes in the base deployment, and any enhancements that you'd like to make from there

## Completed

- [x] write customization info for the site settings config map

- [x] yaml example for lightstep tokens

- [x] write about configuring TLS
