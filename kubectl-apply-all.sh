#!/bin/bash
#
# This file should contain `kubectl apply` commands for all of your configured resources.
#
# This file should be run:
#   * When the cluster is first created
#   * Whenever the configuration for any resource has been updated
#
# The --prune flag is destructive and should always be used
# in conjunction with -f base and -l deploy=sourcegraph. Otherwise, it will delete all resources
# previously created by create or apply that are not specified in the command.
#
# Apply the base Soucegraph deployment
# shellcheck disable=SC2068

# Run the DB migration job and wait for it to complete
kubectl delete -f base/migrator/migrator.Job.yaml --ignore-not-found=true
kubectl apply -f base/migrator/migrator.Job.yaml
kubectl wait -f base/migrator/migrator.job.yaml --for=condition=complete --timeout=-1s

kubectl apply --prune -l deploy=sourcegraph -f base --recursive $@
