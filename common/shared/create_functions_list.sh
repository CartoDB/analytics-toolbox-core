#!/usr/bin/env bash

# Script to create a list with all the functions in the Analytics Toolbox

export GIT_DIFF=off

echo "Serializing function names inside funct_names.csv";

SCRIPT_DIR=$( dirname "$0" )
SCRIPTS_DIR=$SCRIPT_DIR/../../scripts
echo ${SCRIPTS_DIR}
if [ -z ${ROOT_DIR} ];
then
    ROOT_DIR=$SCRIPT_DIR/../..
fi
if [ -z ${DIST_DIR} ];
then
    DIST_DIR=$ROOT_DIR/dist
fi

rm -rf $DIST_DIR
mkdir -p $DIST_DIR

for module in `node ${SCRIPTS_DIR}/modulesort.js`; do
    echo ""
    echo "> Module $module/$CLOUD"
    make -C $ROOT_DIR/modules/$module/$CLOUD serialize-functions || exit 1
    cat $ROOT_DIR/modules/$module/$CLOUD/dist/funct_names.csv >> $DIST_DIR/funct_names.csv
    rm -f $ROOT_DIR/modules/$module/$CLOUD/dist/funct_names.csv
done