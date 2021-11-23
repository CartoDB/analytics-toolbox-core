#!/usr/bin/env bash

# Script to create a Spatial Extension package for Redshift

#PACKAGE_TYPE=CORE

PACKAGE_VERSION=$(date +%Y.%m.%d)

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

# Generate version
echo $PACKAGE_VERSION > $DIST_DIR/version

# Generate modules.sql
export CLOUD=redshift
export GIT_DIFF=off
for module in `node ${SCRIPTS_DIR}/modulesort.js`; do
    echo -e "\n> Module $module/$CLOUD"
    make -C $ROOT_DIR/modules/$module/$CLOUD serialize-module \
        PACKAGE_VERSION=$PACKAGE_VERSION VERSION_FUNCTION=VERSION_$PACKAGE_TYPE || exit 1
    cat $ROOT_DIR/modules/$module/$CLOUD/dist/module.sql >> $DIST_DIR/modules.sql
    rm -f $ROOT_DIR/modules/$module/$CLOUD/dist/module.sql
    mkdir -p $DIST_DIR/libs
    mv $ROOT_DIR/modules/$module/$CLOUD/dist/*.zip $DIST_DIR/libs
done
