#!/usr/bin/env bash

# Script to copy module permissions from one module to another.

# * BQ_PROJECT
# * BQ_PERMISSIONS_ROLE_NAME
# * BQ_PERMISSIONS_SOURCE_DATASET
# * BQ_PERMISSIONS_TARGET_DATASET

if [ "$BQ_PERMISSIONS_ROLE_NAME" = "" ]; then
    echo "  BQ_PERMISSIONS_ROLE_NAME must be defined!"
    exit 1
fi

BQ_PERMISSIONS_ROLE=projects/$BQ_PROJECT/roles/$BQ_PERMISSIONS_ROLE_NAME

echo "Copying permissions from $BQ_PROJECT:$BQ_PERMISSIONS_SOURCE_DATASET to $BQ_PROJECT:$BQ_PERMISSIONS_TARGET_DATASET"

if [ "$BQ_PERMISSIONS_TARGET_DATASET" = "$BQ_PERMISSIONS_SOURCE_DATASET" ]; then
    echo "  Nothing to do!"
    exit 0
fi

PERMISSIONS_TEMPFILE_OLD=$(mktemp -u /tmp/old_module_permissions_XXXXXXXXXXXXXXXXX)
PERMISSIONS_TEMPFILE_NEW=$(mktemp -u /tmp/new_module_permissions_XXXXXXXXXXXXXXXXX)
PERMISSIONS_TEMPFILE_FINAL=$(mktemp -u /tmp/new_module_permissions_XXXXXXXXXXXXXXXXX)

bq show --format=prettyjson ${BQ_PROJECT}:${BQ_PERMISSIONS_SOURCE_DATASET} > ${PERMISSIONS_TEMPFILE_OLD}
bq show --format=prettyjson ${BQ_PROJECT}:${BQ_PERMISSIONS_TARGET_DATASET} > ${PERMISSIONS_TEMPFILE_NEW}
jq --argjson access "$( jq -c '[.access[] | select( .role == "'${BQ_PERMISSIONS_ROLE}'" )]' ${PERMISSIONS_TEMPFILE_OLD} )" \
   '.access += $access' ${PERMISSIONS_TEMPFILE_NEW} > ${PERMISSIONS_TEMPFILE_FINAL}
bq update --source ${PERMISSIONS_TEMPFILE_FINAL} ${BQ_PROJECT}:${BQ_PERMISSIONS_TARGET_DATASET}

rm -f ${PERMISSIONS_TEMPFILE_OLD}*
rm -f ${PERMISSIONS_TEMPFILE_NEW}*
rm -f ${PERMISSIONS_TEMPFILE_FINAL}*