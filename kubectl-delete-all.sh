#!/bin/bash
#
# This file should contain `kubectl delete` commands for all of your configured resources.
#
# This file should be run:
#   * When you want to clean-up all resources created
#
# Remove the base Soucegraph deployment
# shellcheck disable=SC2068
kubectl delete -f base --recursive $@
