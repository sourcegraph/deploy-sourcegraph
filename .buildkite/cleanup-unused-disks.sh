#!/usr/bin/env bash
# Deletes unattached GCP disks from the "Sourcegraph Auxiliary" project

set -euxo pipefail

SOURCEGRAPH_AUXILIARY_PROJECT=sourcegraph-server

gcloud_command() {
    gcloud --quiet --project="$SOURCEGRAPH_AUXILIARY_PROJECT" "$@"
}

echo "--- Deleting unattached GCP disks from the '$SOURCEGRAPH_AUXILIARY_PROJECT' project"

# See https://groups.google.com/d/msg/gce-discussion/RLrwOx8fazo/9ve7lIdsBQAJ for more information.
unattached_disks=$(gcloud_command compute disks list --filter="-users:*" --format="value(selfLink)")

for disk in unattached_disks
do
    echo "Deleting disk: $disk"
    
    # "gcloud compute disks delete ..." will never delete an attached disk.
    # See https://cloud.google.com/sdk/gcloud/reference/compute/disks/delete for more information.
    gcloud_command compute disks delete $disk
done

echo "done"
