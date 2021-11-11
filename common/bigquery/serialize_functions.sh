#!/usr/bin/env bash

# Script to serialize all the functions in the Analytics Toolbox

export CLOUD=bigquery
export GIT_DIFF=off

SCRIPT_DIR=$( dirname "$0" )

SOURCE_DIR=$1
DIST_DIR=$2

rm -rf $DIST_DIR
mkdir -p $DIST_DIR

for module in `cd $SOURCE_DIR; node scripts/modulesort.js`; do
    echo "> Module $module/$CLOUD"
    make -C $SOURCE_DIR/modules/$module/$CLOUD serialize-functions || exit 1
    cat $SOURCE_DIR/modules/$module/$CLOUD/dist/funct_names.csv >> $DIST_DIR/funct_names.csv
    rm -f $SOURCE_DIR/modules/$module/$CLOUD/dist/funct_names.csv
done