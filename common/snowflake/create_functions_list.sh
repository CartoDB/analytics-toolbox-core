#!/usr/bin/env bash

# Script to create a list wiht all the functions in the Analytics Toolbox

export CLOUD=snowflake
export GIT_DIFF=off

echo "Serializing function names inside funct_names.csv";

SCRIPT_DIR=$( dirname "$0" )

ROOT_DIR=$SCRIPT_DIR/../..
DIST_DIR=$ROOT_DIR/dist

rm -rf $DIST_DIR
mkdir -p $DIST_DIR

for module in `cd $ROOT_DIR; node scripts/modulesort.js`; do
    echo ""
    echo "> Module $module/$CLOUD"
    make -C $ROOT_DIR/modules/$module/$CLOUD serialize-functions || exit 1
    cat $ROOT_DIR/modules/$module/$CLOUD/dist/funct_names.csv >> $DIST_DIR/funct_names.csv
    rm -f $ROOT_DIR/modules/$module/$CLOUD/dist/funct_names.csv
done