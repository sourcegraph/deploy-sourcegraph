#!/bin/bash
#
# This file should be filled in by customers with simple `kubectl` commands that should be run on
# new cluster creation.  As a general rule, these commands should create Kubernetes objects that
# satisfy one of the following conditions:
#
#   * The object is a secret that shouldn't be committed to version control.
#   * The object will never be updated after creation (e.g., a network load balancer).
#
# Objects that do not meet the above criteria should NOT be created by this script. Instead, create
# a YAML file that can be `kubectl apply`d to the cluster, and version that file in this repository.
