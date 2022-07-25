#!/usr/bin/env bash

# Script to create a Spatial Extension package for BigQuery

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

export GIT_DIFF=off
export CLOUD=bigquery
export PACKAGE_NAME=${PACKAGE_NAME:=carto-analytics-toolbox-core-$CLOUD}
export PACKAGE_VERSION=$(cat $ROOT_DIR/common/$CLOUD/version)
export PACKAGE_FULL_NAME=$PACKAGE_NAME-$PACKAGE_VERSION

DIST_PACKAGE_DIR=$DIST_DIR/$PACKAGE_FULL_NAME

echo "Creating installation package '$CLOUD-v$PACKAGE_VERSION'";

rm -rf $DIST_DIR
mkdir -p $DIST_PACKAGE_DIR
mkdir -p $DIST_PACKAGE_DIR/libs

for module in `node ${SCRIPTS_DIR}/modulesort.js`; do
    echo -e "\n> Module $module/$CLOUD"
    make -C $ROOT_DIR/modules/$module/$CLOUD serialize-module  || exit 1
    cat $ROOT_DIR/modules/$module/$CLOUD/dist/module-header.sql >> $DIST_PACKAGE_DIR/modules-header.sql
    cat $ROOT_DIR/modules/$module/$CLOUD/dist/module.sql >> $DIST_PACKAGE_DIR/modules-content.sql
    cat $ROOT_DIR/modules/$module/$CLOUD/dist/module-footer.sql > $DIST_PACKAGE_DIR/modules-footer.sql
    cp $ROOT_DIR/modules/$module/$CLOUD/dist/index.js $DIST_PACKAGE_DIR/libs/${module}Lib.js
done

cat $DIST_PACKAGE_DIR/modules-header.sql $DIST_PACKAGE_DIR/modules-content.sql $DIST_PACKAGE_DIR/modules-footer.sql > $DIST_PACKAGE_DIR/modules.sql
rm $DIST_PACKAGE_DIR/modules-header.sql
rm $DIST_PACKAGE_DIR/modules-content.sql
rm $DIST_PACKAGE_DIR/modules-footer.sql

cd $DIST_DIR
zip $PACKAGE_FULL_NAME.zip -r $PACKAGE_FULL_NAME/
cd ..