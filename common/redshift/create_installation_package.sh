#!/usr/bin/env bash

# Script to create a Spatial Extension package for Redshift

export PACKAGE_TYPE=${PACKAGE_TYPE:=CORE}
PACKAGE_VERSION=$(date +%Y.%m.%d)

echo "Creating installation package $PACKAGE_VERSION";

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

# Generate SQL scripts and libs
export CLOUD=redshift
export GIT_DIFF=off
mkdir -p $DIST_DIR/libs
for module in `node ${SCRIPTS_DIR}/modulesort.js`; do
    echo -e "\n> Module $module/$CLOUD"
    make -C $ROOT_DIR/modules/$module/$CLOUD serialize-module \
        PACKAGE_VERSION=$PACKAGE_VERSION || exit 1
    touch $DIST_DIR/modules-header.sql
    if [ "$PACKAGE_TYPE" = "CORE" ]; then
        cat $ROOT_DIR/modules/$module/$CLOUD/dist/module-header.sql > $DIST_DIR/modules-header.sql
    fi
    cat $ROOT_DIR/modules/$module/$CLOUD/dist/module.sql >> $DIST_DIR/modules-content.sql
    cat $ROOT_DIR/modules/$module/$CLOUD/dist/module-footer.sql > $DIST_DIR/modules-footer.sql
    cat $ROOT_DIR/modules/$module/$CLOUD/dist/libraries.sql >> $DIST_DIR/libraries.sql
    cp $ROOT_DIR/modules/$module/$CLOUD/dist/*.zip $DIST_DIR/libs
done
cat $DIST_DIR/modules-header.sql $DIST_DIR/modules-content.sql $DIST_DIR/modules-footer.sql > $DIST_DIR/modules.sql
