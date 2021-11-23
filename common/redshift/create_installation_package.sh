#!/usr/bin/env bash

# Script to create a Spatial Extension package for Redshift

PACKAGE_NAME="carto-spatial-extension-redshift"

echo "Creating installation package $PACKAGE_NAME.zip";

SCRIPT_DIR=$( dirname "$0" )
SCRIPTS_DIR=$SCRIPT_DIR/../../SCRIPTS_DIR

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
    echo -e "\n> Module $module/$CLOUD"
    make -C $ROOT_DIR/modules/$module/$CLOUD serialize-module || exit 1
    mv $ROOT_DIR/modules/$module/$CLOUD/dist/*.zip $DIST_DIR
    cat $ROOT_DIR/modules/$module/$CLOUD/dist/module.sql >> $DIST_DIR/modules.sql
    rm -f $ROOT_DIR/modules/$module/$CLOUD/dist/module.sql
    # mkdir -p $DIST_DIR/lib/$module
done


# Generate core modules
# $SCRIPT_DIR/serialize_modules.sh $ROOT_DIR/core $DIST_DIR/core
# mv $DIST_DIR/core/*.zip $DIST_DIR
# cat $DIST_DIR/core/modules.sql >> $DIST_DIR/modules.sql
# rm -rf $DIST_DIR/core

# # Generate advanced modules
# $SCRIPT_DIR/serialize_modules.sh $ROOT_DIR $DIST_DIR/advanced
# mv $DIST_DIR/advanced/*.zip $DIST_DIR
# cat $DIST_DIR/advanced/modules.sql >> $DIST_DIR/modules.sql
# rm -rf $DIST_DIR/advanced
