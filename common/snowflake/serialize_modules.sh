#!/usr/bin/env bash

# Script to serialize both the SQL and JS code used for the creation of a installation package

export CLOUD=snowflake
export GIT_DIFF=off

SCRIPT_DIR=$( dirname "$0" )

SOURCE_DIR=$1
DIST_DIR=$2

rm -rf $DIST_DIR
mkdir -p $DIST_DIR

for module in `cd $SOURCE_DIR; node scripts/modulesort.js`; do
    echo "> Module $module/$CLOUD"
    make -C $SOURCE_DIR/modules/$module/$CLOUD serialize-module || exit 1
    cat $SOURCE_DIR/modules/$module/$CLOUD/dist/module.sql >> $DIST_DIR/modules.sql
    rm -f $SOURCE_DIR/modules/$module/$CLOUD/dist/module.sql
done