# Development

## Cutting a release

- Make the desired changes to this repository.

  - Updating image tags:

    - The vast majority of the time, [Renovate](https://renovatebot.com/docs/docker/) will open PRs in a timely manner.

    - If you want to update them manually, you can update the Docker image versions in `*.Deployment.yaml` to match the tagged version you are releasing.

      - You should look at our [DockerHub repositories](https://hub.docker.com/r/sourcegraph/) to see what the latest versions are.

      - Make sure to include the sha256 digest for each image, which [ensures that each image pull is immutable](https://renovatebot.com/docs/docker/#digest-pinning). Use `docker inspect --format='{{index .RepoDigests 0}}' $IMAGE` to get the digest.

- Open a PR and wait for buildkite to pass and for your changes to be approved, then merge and check out master.
- Test what is currently checked in to master by [installing](docs/install.md) Sourcegraph on a fresh cluster:
  - Provision a new cluster:
    1.  Create a cluster unique name that is identifiable to you (e.g `ggilmore-test`) in the [Sourcegraph Auxiliary GCP Project](https://console.cloud.google.com/kubernetes/list?project=sourcegraph-server&organizationId=1006954638239). You can create pool that has `3` nodes, each with `8` vCPUs and `30` GB memory (for a total of `24` vCPUs and `90` GB memory).
        - See this screenshot, but note that the UI could have changed: ![](https://imgur.com/RuCyGX2.png)
    1.  It’ll take a few minutes for it to be provisioned, you’ll see a green checkmark when it is done.
    1.  Click on the `connect` button next to your cluster, it’ll give you a command to copy+paste in your terminal.
    1.  Run the command in your terminal. Once it finishes, run `kubectl config current-context`. It should tell you that it’s set up to talk to the cluster that you just created.
  - Do the same smoke tests that we do for `sourcegraph/sourcegraph` (check to see that the new release works, check to see that the upgrade path works)
    - Check to see that the latest `master` is working on a fresh cluster
      1. Deploy the latest `master` to your new cluster by running through the quickstart steps in [docs/install.md](docs/install.md)
         - You'll need to create a GCP Storage Class named `sourcegraph` with the same `zone` that you created your cluster in (see ["Configure a storage class"](./docs/configure.md#Configure-a-storage-class))
         - In order to give yourself permissions to create roles on the cluster, run: `kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user $YOUR_NAME@sourcegraph.com`
      1. Use the instructions in [configure.md](./docs/configure.md) to add a repository, test that code intelligence is working on it, and do a couple searches
    - Check the upgrade path from the previous release to the laster `master`
      1. Tear down the cluster that you created above
      1. Checkout the commit that contains the configuration for the previous release (e.g. the commit has `2.11.x` images if you're currently trying to release `2.12.x`, etc.), and use the instructions above to create a new cluster, deploy the older commit to it, and do the same smoke tests with the older version
      1. Checkout the latest `master`, deploy the newer images to the same cluster (without tearing it down in between) by running `./kubectl-apply-all.sh`, and check to see the smoke test passes after the upgrade process

* The version numbers for [sourcegraph/deploy-sourcegraph](https://github.com/sourcegraph/deploy-sourcegraph) follows [sourcegraph/sourcegraph](https://github.com/sourcegraph/sourcegraph)'s version numbers (i.e. `deploy-sourcegraph@v2.11.2` uses [sourcegraph/sourcegraph](https://github.com/sourcegraph/sourcegraph)'s `v2.11.2` image tags). Here is [sourcegraph/deploy-sourcegraph](https://github.com/sourcegraph/deploy-sourcegraph)'s branching strategy:

  - **If you are cutting a new minor version (e.g. `v2.12.0`)**:

    - Make a branch named `v2.12` that stems from the current `master` branch and push it. `v2.12` will be used as the base for all `v2.12.x` images, and future changes to the `v2.12.x` series will be cherry-picked onto it and tagged from there.

      ```bash
      git checkout master
      git pull # make sure that you're up to date
      git checkout -b v2.12
      git push --set-upstream origin v2.12
      ```

    - Follow the tagging instructions below to tag the `v2.12.0` release from the `v2.12` branch.

  - **If you are cutting a new patch version (e.g. `v2.12.1`)**:

    - Cherry-pick the relevant commits from `master` that update the image tags to `v2.12.1` onto the `v2.12` branch (which should have been created as mentioned above).

      ```bash
      git checkout v2.12
      git pull # make sure that you're up to date
      git cherry-pick commit0 commit1 ... # all relevant commits from the master branch
      git push
      ```

    - Follow the tagging instructions below to tag the `v2.12.1` release from the `v2.12` branch.

  - **If you are only updating the Kubernetes manifests / docs, but not touching image tags** (see [this commit](https://github.com/sourcegraph/deploy-sourcegraph/commit/1d1846f67c01ad2a81741cf95ee867405d3de3ab) as an example):

    - Cherry-pick the relevant commits from `master` that update the manifests/docs onto the `v2.12` branch.

      ```bash
      git checkout v2.12
      git pull # make sure that you're up to date
      git cherry-pick commit0 commit1 ... # all relevant commits from the master branch
      git push
      ```

    - We mark these kinds of releases with a version number that looks like `v2.12.0-2` (Note the `-2` suffix, which increments with each update like this that affects the `v2.12.0` series. Look at [the releases page](https://github.com/sourcegraph/deploy-sourcegraph/releases), and pick the `suffix` that's next in the series). Follow the tagging instructions below to tag the `v2.12.0-2` release from the `v2.12` branch.

- Create a git tag and push it to the repository:

  ```bash
  VERSION = vX.Y.Z

  # If this is a release candidate: VERSION = `vX.Y.Z-pre${N}` (where `N` starts at 0 and increments as you test/cut new versions)

  # 🚨 Make sure that you have the commit that you want to tag as $VERSION checked out!

  git tag $VERSION
  git push origin $VERSION
  ```

- Cut the legacy Helm version of the release (this step will be deprecated after the next iteration):

  - checkout [deploy-sourcegraph@helm-legacy](https://github.com/sourcegraph/deploy-sourcegraph/tree/helm-legacy)
  - update the image tags in [yalues.yaml](https://github.com/sourcegraph/deploy-sourcegraph/blob/helm-legacy/values.yaml)
  - run [generate.sh](https://github.com/sourcegraph/deploy-sourcegraph/blob/helm-legacy/generate.sh)
  - run [release.sh](https://github.com/sourcegraph/deploy-sourcegraph/blob/helm-legacy/release.sh)

- [Update the `latestReleaseDataCenterBuild` value in `sourcegraph/sourcegraph`](https://sourcegraph.sgdev.org/github.com/sourcegraph/sourcegraph/-/blob/cmd/server/README.md#5-notify-existing-instances-that-an-update-is-available)
