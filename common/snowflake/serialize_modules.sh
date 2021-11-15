#!/usr/bin/env bash

# Script to serialize both the SQL and JS code used for the creation of a installation package

export CLOUD=snowflake
export GIT_DIFF=off

SCRIPT_DIR=$( dirname "$0" )

SOURCE_DIR=$1
DIST_DIR=$2
INSTALLATION_FILE="sf_installation_package.sql"

rm -rf $DIST_DIR
mkdir -p $DIST_DIR

for module in `cd $SOURCE_DIR; node scripts/modulesort.js`; do
    echo "> Module $module/$CLOUD"
    INSTALLATION_FILE=$INSTALLATION_FILE make -C $SOURCE_DIR/modules/$module/$CLOUD serialize-module || exit 1
    cat $SOURCE_DIR/modules/$module/$CLOUD/dist/$INSTALLATION_FILE >> $DIST_DIR/$INSTALLATION_FILE
    rm -f $SOURCE_DIR/modules/$module/$CLOUD/dist/$INSTALLATION_FILE
done