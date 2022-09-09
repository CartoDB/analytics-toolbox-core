#!/usr/bin/env bash

# Script to set module permissions.

# * BQ_PROJECT
# * BQ_PERMISSIONS
# * BQ_PERMISSIONS_TARGET_DATASET

echo "Setting permissions to $BQ_PROJECT:$BQ_PERMISSIONS_TARGET_DATASET"

PERMISSIONS_TEMPFILE_OLD=$(mktemp -u /tmp/old_module_permissions_XXXXXXXXXXXXXXXXX)
PERMISSIONS_TEMPFILE_NEW=$(mktemp -u /tmp/new_module_permissions_XXXXXXXXXXXXXXXXX)

bq show --format=prettyjson ${BQ_PROJECT}:${BQ_PERMISSIONS_TARGET_DATASET} > ${PERMISSIONS_TEMPFILE_OLD}
jq --argjson access "$BQ_PERMISSIONS" \
   '.access += $access' ${PERMISSIONS_TEMPFILE_OLD} > ${PERMISSIONS_TEMPFILE_NEW}
bq update --source ${PERMISSIONS_TEMPFILE_NEW} ${BQ_PROJECT}:${BQ_PERMISSIONS_TARGET_DATASET}

rm -f ${PERMISSIONS_TEMPFILE_OLD}*
rm -f ${PERMISSIONS_TEMPFILE_NEW}*