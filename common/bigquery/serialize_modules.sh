#!/usr/bin/env bash

# Script to serialize both the SQL and JS code used for the creation of a installation package

export CLOUD=bigquery
export GIT_DIFF=off

SCRIPT_DIR=$( dirname "$0" )

SOURCE_DIR=$1
DIST_DIR=$2

rm -rf $DIST_DIR
mkdir -p $DIST_DIR

for module in `cd $SOURCE_DIR; node scripts/modulesort.js`; do
    echo -e "\n> Module $module/$CLOUD"
    make -C $SOURCE_DIR/modules/$module/$CLOUD serialize-module || exit 1
    sed -e "s!@@BQ_LIBRARY_BUCKET@@!@@BQ_LIBRARY_BUCKET@@/libs/$module/index.js!g" $SOURCE_DIR/modules/$module/$CLOUD/dist/module.sql >> $SOURCE_DIR/modules/$module/$CLOUD/dist/module_rep.sql
    cat $SOURCE_DIR/modules/$module/$CLOUD/dist/module_rep.sql >> $DIST_DIR/modules.sql
    rm -f $SOURCE_DIR/modules/$module/$CLOUD/dist/module.sql $SOURCE_DIR/modules/$module/$CLOUD/dist/module_rep.sql
    mkdir -p $DIST_DIR/libs/$module
    cp $SOURCE_DIR/modules/$module/$CLOUD/dist/index.js $DIST_DIR/libs/$module/index.js
done