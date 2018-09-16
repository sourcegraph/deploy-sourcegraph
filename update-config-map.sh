#!/bin/bash

# e.g. 2018-08-15t23-42-08z
CONFIG_DATE=$(date -u +"%Y-%m-%dt%H-%M-%Sz")

# update all references to the site config's ConfigMap
# from: 'config-file.*' , to:' config-file-$CONFIG_DATE'
find . -name "*yaml" -exec sed -i.sedibak -e "s/name: config-file.*/name: config-file-$CONFIG_DATE/g" {} +

# delete sed's backup files
find . -name "*.sedibak" -delete
