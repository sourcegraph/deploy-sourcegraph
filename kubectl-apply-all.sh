#!/bin/bash
#
# This file should contain `kubectl apply` commands for all of your configured resources.
# 
# This file should be run:
#   * When the cluster is first created
#   * Whenever the configuration for any resource has been updated

# This way every config update has a version that shows when it was applied.
updateConfigVersion() {
  # e.g. 2018-08-15t23-42-08z
  config_date=$(date -u +"%Y-%m-%dt%H-%M-%Sz")

  # update all references to the site config's ConfigMap
  # from: 'config-file.*' , to:' config-file-$config_date'
  find . -name "*yaml" -exec sed -i.sedibak -e "s/name: config-file.*/name: config-file-${config_date}/g" {} +

  # delete sed's backup files
  find . -name "*.sedibak" -delete
}


# Apply the base Soucegraph deployment 

# Switch kubectl to use the sourcegraph cluster, if it isn't already
gcloud container clusters get-credentials sourcegraph-eu1 --zone europe-west1-d --project solar-virtue-183310

updateConfigVersion

# Start up base services
kubectl apply --prune -l deploy=sourcegraph -f base --recursive

# And switch on keycloak
kubectl apply -f keycloak

# Next, redeploy the xlang services
kubectl apply --prune -l deploy=xlang-typescript -f configure/xlang/typescript/ --recursive
kubectl apply --prune -l deploy=xlang-python -f configure/xlang/python/ --recursive
kubectl apply --prune -l deploy=xlang-php -f configure/xlang/php/ --recursive
kubectl apply --prune -l deploy=xlang-java -f configure/xlang/java/ --recursive
kubectl apply --prune -l deploy=xlang-go -f configure/xlang/go/ --recursive

# Include some of the experimental ones, too
kubectl apply --prune -l deploy=xlang-bash -f configure/xlang/experimental/bash --recursive
kubectl apply --prune -l deploy=xlang-cpp -f configure/xlang/experimental/cpp --recursive
kubectl apply --prune -l deploy=xlang-cs -f configure/xlang/experimental/cs --recursive
kubectl apply --prune -l deploy=xlang-css -f configure/xlang/experimental/css --recursive
kubectl apply --prune -l deploy=xlang-dockerfile -f configure/xlang/experimental/dockerfile --recursive
kubectl apply --prune -l deploy=xlang-html -f configure/xlang/experimental/html --recursive
kubectl apply --prune -l deploy=xlang-lua -f configure/xlang/experimental/lua --recursive
kubectl apply --prune -l deploy=xlang-ruby -f configure/xlang/experimental/ruby --recursive
