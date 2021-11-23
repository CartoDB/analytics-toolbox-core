#!/usr/bin/env bash

# Script to create a Spatial Extension package for Redshift

PACKAGE_NAME="carto-spatial-extension-redshift"

echo "Creating installation package $PACKAGE_NAME.zip";

SCRIPT_DIR=$( dirname "$0" )
SCRIPTS_DIR=$SCRIPT_DIR/../../scripts
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

# Generate modules.sql
export CLOUD=redshift
export GIT_DIFF=off
for module in `node ${SCRIPTS_DIR}/modulesort.js`; do
    echo -e "\n> Module $module/$CLOUD"
    make -C $ROOT_DIR/modules/$module/$CLOUD serialize-module || exit 1
    mv $ROOT_DIR/modules/$module/$CLOUD/dist/*.zip $DIST_DIR
    cat $ROOT_DIR/modules/$module/$CLOUD/dist/module.sql >> $DIST_DIR/modules.sql
    rm -f $ROOT_DIR/modules/$module/$CLOUD/dist/module.sql

done
