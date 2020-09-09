# Deploy-Sourcegraph Developer Guide

- [Docker images](#docker-images)
  - [Cutting a release](#cutting-a-release)
  - [Manual image updates](#manual-image-updates)
- [Testing changes](#testing-changes)
  - [Open a PR](#open-a-pr)
  - [Smoke test](#smoke-test)
    - [Using the sourcegraph/deploy-k8s-helper tool](#using-the-sourcegraphdeploy-k8s-helper-tool)
      - [Do smoke tests for `master` branch](#do-smoke-tests-for-master-branch)
      - [Check the upgrade path from the previous release to `master`](#check-the-upgrade-path-from-the-previous-release-to-master)
    - [Manual instructions](#manual-instructions)
      - [Provision a new cluster](#provision-a-new-cluster)
      - [Do smoke tests for `master` branch](#do-smoke-tests-for-master-branch-1)
      - [Check the upgrade path from the previous release to `master`](#check-the-upgrade-path-from-the-previous-release-to-master-1)
  - [Minikube](#minikube)

## Docker images

Refer to [deployment basics](https://about.sourcegraph.com/handbook/engineering/deployments#deployment-basics) to learn about Sourcegraph Docker images and [Renovate](https://renovatebot.com/docs/docker/), which performs most image updates.

The `master` branch of this repository is configured to track the latest builds from `sourcegraph/sourgraph@main`, tagged as `insiders`. Renovate automatically performs updates for these images.

Release branches (`3.19`, etc) track specific versions instead, and updates are triggered manually for specific branches - see [cutting a release](#cutting-a-release).

### Cutting a release

The [GitHub Action "Update tags"](https://github.com/sourcegraph/deploy-sourcegraph/actions?query=workflow%3A%22Dispatch+update%22) is used to enforce semver constraints for Sourcegraph Docker images for appropriate release branches (`3.19`, etc). Click "Run workflow" and provide the necessary parameters to open a pull request. You can run the workflow locally as well:

```sh
.github/workflows/scripts/update-docker-tags.sh "~3.19"
```

Once an upgrade is performed, tag the release. The version numbers for [sourcegraph/deploy-sourcegraph](https://github.com/sourcegraph/deploy-sourcegraph) largely follow [sourcegraph/sourcegraph](https://github.com/sourcegraph/sourcegraph)'s version numbers (i.e. `deploy-sourcegraph@v2.11.2` uses [sourcegraph/sourcegraph](https://github.com/sourcegraph/sourcegraph)'s `v2.11.2` image tags).

Refer to [releases](https://about.sourcegraph.com/handbook/engineering/releases) for more details.

### Manual image updates

In most cases, you should not do this in `deploy-sourcegraph` itself, but in relevant forks instead - see the [installation](https://docs.sourcegraph.com/admin/install/kubernetes) guide.

If you want to update Docker images manually, you can update the Docker image versions in `*.Deployment.yaml` to match the tagged version that you are releasing. You should look at our [DockerHub repositories](https://hub.docker.com/r/sourcegraph/) to see what the latest versions are. Make sure to include the sha256 digest for each image, which [ensures that each image pull is immutable](https://renovatebot.com/docs/docker/#digest-pinning). Use `docker inspect --format='{{index .RepoDigests 0}}' $IMAGE` to get the digest.

## Testing changes

### Open a PR

Wait for buildkite to pass and for your changes to be approved, then merge and check out `master`.

### Smoke test

Test what is currently checked in to master by [installing](docs/install.md) Sourcegraph on a fresh cluster.

#### Using the sourcegraph/deploy-k8s-helper tool

Clone [`sourcegraph/deploy-k8s-helper`](https://github.com/sourcegraph/deploy-k8s-helper) to your machine and follow the [README](https://github.com/sourcegraph/deploy-k8s-helper/blob/master/README.md) to set up all the prerequisistes.

##### Do smoke tests for `master` branch

1. Ensure that the `deploySourcegraphRoot` value in your stack configuration (see https://github.com/sourcegraph/deploy-k8s-helper/blob/master/README.md) is pointing to your deploy-sourcegraph checkout (ex: `pulumi config set deploySourcegraphRoot /Users/ggilmore/dev/go/src/github.com/sourcegraph/deploy-sourcegraph`)
1. In your deploy-sourcegraph checkout, make sure that you're on the latest `master`
1. Run `yarn up` in your https://github.com/sourcegraph/deploy-k8s-helper checkout
1. It'll take a few minutes for the cluster to be provisioned and for sourcegraph to be installed. Pulumi will show you the progresss that it's making, and will tell you when it's done. 
1. Use the instructions in [configure.md](docs/configure.md) to:
   1. Add a repository (e.g. [sourcegraph/sourcegraph](https://github.com/sourcegraph/sourcegraph))
   1. Enable a language extension (e.g. [Go](https://sourcegraph.com/extensions/sourcegraph/lang-go)), and test that code intelligence is working on the above repository
   1. Do a few test searches
1. When you're done, run `yarn destroy` to tear the cluster down. This can take ~10 minutes.

##### Check the upgrade path from the previous release to `master`

1. In your deploy-sourcegraph checkout, checkout the commit that contains the configuration for the previous release (e.g. the commit that has `2.11.x` images if you're currently trying to release `2.12.x`, etc.)
1. Run `yarn up` in your https://github.com/sourcegraph/deploy-k8s-helper checkout
1. Do [the same smoke tests that you did above](#Do-smoke-tests-for-master-branch)
1. In your deploy-sourcegraph checkout, checkout the latest `master` commit again and run `yarn up` to deploy the new images. Check to see that [the same smoke tests](#Do-smoke-tests-for-master-branch) pass after the upgrade process.
1. When you're done, run `yarn destroy` to tear the cluster down.

#### Manual instructions

##### Provision a new cluster

Refer to [how to deploy a test cluster](https://about.sourcegraph.com/handbook/engineering/deployments#test-clusters).

##### Do smoke tests for `master` branch

1. Deploy the latest `master` to your new cluster by running through the quickstart steps in [docs/install.md](docs/install.md)
   - You'll need to create a GCP Storage Class named `sourcegraph` with the same `zone` that you created your cluster in (see ["Configure a storage class"](docs/configure.md#Configure-a-storage-class))
   - In order to give yourself permissions to create roles on the cluster, run: `kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user $YOUR_NAME@sourcegraph.com`
1. Use the instructions in [configure.md](docs/configure.md) to:
   1. Add a repository (e.g. [sourcegraph/sourcegraph](https://github.com/sourcegraph/sourcegraph))
   1. Enable a language extension (e.g. [Go](https://sourcegraph.com/extensions/sourcegraph/lang-go)), and test that code intelligence is working on the above repository
   1. Do a couple test searches

##### Check the upgrade path from the previous release to `master`

1. Tear down the cluster that you created above by deleting it through from the [Sourcegraph Auxiliary GCP Project](https://console.cloud.google.com/kubernetes/list?project=sourcegraph-server&organizationId=1006954638239).
1. Checkout the commit that contains the configuration for the previous release (e.g. the commit has `2.11.x` images if you're currently trying to release `2.12.x`, etc.)
1. [Use the "Provision a new cluster" instructions above](#Provision-a-new-cluster) to create a new cluster.
1. Deploy the older commit to the new cluster, and do [the same smoke tests](#Do-smoke-tests-for-master-branch) with the older version.
1. Checkout the latest `master`, deploy the newer images to the same cluster (without tearing it down in between) by running `./kubectl-apply-all.sh`, and check to see [that the smoke test](#Do-smoke-tests-for-master-branch) passes after the upgrade process.

### Minikube

You can use minikube to run Sourcegraph Cluster on your development machine. However, due to minikube requirements and reduced available resources we need to modify the resources to remove `resources` requests/limits and `storageClassNames`. Here is the shell commands you can use to spin up minikube:

```shell
find base -name '*Deployment.yaml' | while read i; do yj < $i | jq 'walk(if type == "object" then del(.resources) else . end)' | jy -o $i; done
find base -name '*PersistentVolumeClaim.yaml' | while read i; do yj < $i | jq 'del(.spec.storageClassName)' | jy -o $i; done
find base -name '*StatefulSet.yaml' | while read i; do yj < $i | jq 'del(.spec.volumeClaimTemplates[] | .spec.storageClassName) | del(.spec.template.spec.containers[] | .resources)' | jy -o $i; done
minikube start
kubectl create ns src
kubens src
./kubectl-apply-all.sh
kubectl expose deployment sourcegraph-frontend --type=NodePort --name sourcegraph --port=3080 --target-port=3080
minikube service list
```

Additionally you may want to deploy a modified version of a service locally. Minikube allows us to directly connect to its docker instance, making it easy to use unpublished images from the sourcegraph repository:

```shell
eval $(minikube docker-env)
IMAGE=repo-updater:dev ./cmd/repo-updater/build.sh
kubectl edit deployment/repo-updater # set imagePullPolicy to Never
kubectl set image deployment repo-updater '*=repo-updater:dev'
```

You can also use the [minikube overlay](overlays/minikube/README.md). This avoids modifying the config files in `base`.
