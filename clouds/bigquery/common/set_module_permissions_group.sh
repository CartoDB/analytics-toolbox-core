#!/usr/bin/env bash

# Script to set module permissions to a Google group email.

# * BQ_PROJECT
# * BQ_PERMISSIONS_GROUP
# * BQ_PERMISSIONS_ROLE_NAME
# * BQ_PERMISSIONS_TARGET_DATASET

#############################################################################################
# We do have spatial extension groups for several environments:
# - spatial_extension_users_la@cartodb.com
# - spatial_extension_users_la-stag@cartodb.com
# - spatial_extension_users_la-dev@cartodb.com
#
# NOTE: We add this logic in the script, to reduce complexity in the github actions workflow
#############################################################################################
BQ_PERMISSIONS_GROUP_ENV="-prod -stag -dev"

if [ "$BQ_PERMISSIONS_ROLE_NAME" = "" ]; then
    echo "  BQ_PERMISSIONS_ROLE_NAME must be defined!"
    exit 1
fi

BQ_PERMISSIONS_ROLE=projects/$BQ_PROJECT/roles/$BQ_PERMISSIONS_ROLE_NAME

PERMISSIONS_TEMPFILE_OLD=$(mktemp -u /tmp/old_module_permissions_XXXXXXXXXXXXXXXXX)
PERMISSIONS_TEMPFILE_NEW=$(mktemp -u /tmp/new_module_permissions_XXXXXXXXXXXXXXXXX)

# Iterate over each set of group + environment
for _ENV in ${BQ_PERMISSIONS_GROUP_ENV}; do
  BQ_PERMISSIONS_GROUP_PER_ENV=$(echo ${BQ_PERMISSIONS_GROUP} | \
    awk -v _env=${_ENV} -F"@" ' { new_group=$1_env"@"$2; gsub("-prod","",new_group); print new_group } ')

  echo "Setting $BQ_PERMISSIONS_GROUP_PER_ENV permissions to $BQ_PROJECT:$BQ_PERMISSIONS_TARGET_DATASET"

  bq show --format=prettyjson ${BQ_PROJECT}:${BQ_PERMISSIONS_TARGET_DATASET} > ${PERMISSIONS_TEMPFILE_OLD}
  jq --argjson access '[{"groupByEmail":"'"$BQ_PERMISSIONS_GROUP_PER_ENV"'","role":"'"$BQ_PERMISSIONS_ROLE"'"}]' \
     '.access += $access' ${PERMISSIONS_TEMPFILE_OLD} > ${PERMISSIONS_TEMPFILE_NEW}
  bq update --source ${PERMISSIONS_TEMPFILE_NEW} ${BQ_PROJECT}:${BQ_PERMISSIONS_TARGET_DATASET}
done

rm -f ${PERMISSIONS_TEMPFILE_OLD}*
rm -f ${PERMISSIONS_TEMPFILE_NEW}*
