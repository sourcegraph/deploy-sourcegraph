# DELETE ME BEFORE MERGING PR

- write overview explaining that Data Center consists of the base deployment, and the rest are "addons" that you can configure separately

  - I think that this should replace everything in install.md

- [x] write customization info for the site settings config map

- verify that language servers will still work without specifying the environment variables (notably the BG ones)

- investigate https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#mounted-configmaps-are-updated-automatically to see if people actually need to handle updating each deployment when updating the site config
