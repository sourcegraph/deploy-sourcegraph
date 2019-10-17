#!/usr/bin/env bash
# Deletes unattached GCP disks from the "Sourcegraph Auxiliary" project

set -euxo pipefail

PROJECT=sourcegraph-server

gcloud_command() {
    gcloud --quiet --project="$PROJECT" "$@"
}

echo "--- Deleting unattached GCP disks from the $PROJECT project"

# See https://groups.google.com/d/msg/gce-discussion/RLrwOx8fazo/9ve7lIdsBQAJ for more information.
for disk in $(gcloud_command compute disks list --filter="-users:*" --format="value(selfLink)")
do
    echo "Deleting disk: $disk"
    gcloud_command compute disks delete $disk
done

echo "Done"
