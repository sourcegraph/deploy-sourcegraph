#!/usr/bin/env bash

set -ex

cd "$(dirname "${BASH_SOURCE[0]}")"/..

export TEST_GCP_PROJECT=sourcegraph-ci
export TEST_GCP_ZONE=us-central1-a

# Temporary fix: delete unattached disks associated with these tests
# https://github.com/sourcegraph/sourcegraph/issues/32916 will implement long-term fix
gcloud compute disks list --filter="name:gke-ds-test AND NOT users:*" --format="value(name)" --project ${TEST_GCP_PROJECT} |
  while read -r disk; do gcloud compute disks delete ${disk} --zone ${TEST_GCP_ZONE} --project ${TEST_GCP_PROJECT} --quiet; done

# Also delete disks created by integration-restricted-test
gcloud compute disks list --filter="description:ds-test-restricted AND NOT users:*" --format="value(name)" --project ${TEST_GCP_PROJECT} |
  while read -r disk; do gcloud compute disks delete ${disk} --zone ${TEST_GCP_ZONE} --project ${TEST_GCP_PROJECT} --quiet; done
