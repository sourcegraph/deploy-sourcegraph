#!/bin/bash
#
# This file should contain `kubectl diff` commands for all of your configured resources.
#
# This file should be run:
#   * Before calling kubectl-apply-all.sh to see what will be changed
#
# The --prune flag is destructive and should always be used
# in conjunction with -f base and -l deploy=sourcegraph. Otherwise, it will delete all resources
# previously created by create or apply that are not specified in the command.
#
# Diff the base Soucegraph deployment
# shellcheck disable=SC2068
kubectl diff -l deploy=sourcegraph -n sourcegraph -f base --recursive $@
