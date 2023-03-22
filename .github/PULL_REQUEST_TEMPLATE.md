### Description

<!-- description here -->

> NOTE:

### Checklist

<!--
  Kubernetes and Docker Compose MUST be kept in sync. You should not merge a change here
  without a corresponding change in the other repository, unless it truly is specific to
  this repository. If uneeded, add link or explanation of why it is not needed here.
-->

- [ ] [CHANGELOG.md](https://github.com/sourcegraph/sourcegraph/blob/main/CHANGELOG.md) updated
- [ ] [K8s Upgrade notes updated](https://github.com/sourcegraph/sourcegraph/blob/main/doc/admin/updates/kubernetes.md)
- [ ] Sister [deploy-sourcegraph-k8s](https://github.com/sourcegraph/deploy-sourcegraph-docker) change:
- [ ] Sister [deploy-sourcegraph-docker](https://github.com/sourcegraph/deploy-sourcegraph-docker) change:
- [ ] All images have a valid tag and SHA256 sum
- [ ] I acknowledge that [deploy-sourcegraph-k8s](https://github.com/sourcegraph/deploy-sourcegraph-k8s) is now the preferred Kubernetes deployment repository

### Test plan

<!--
  As part of SOC2/GN-104 and SOC2/GN-105 requirements, all pull requests are REQUIRED to
  provide a "test plan". A test plan is a loose explanation of what you have done or
  implemented to test this, as outlined in our Testing principles and guidelines:
  https://docs.sourcegraph.com/dev/background-information/testing_principles
  Write your test plan here after the "Test plan" header.
-->
