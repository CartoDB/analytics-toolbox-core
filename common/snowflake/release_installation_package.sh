#!/usr/bin/env bash

# Script to release an Analytics Toolbox package for Snowflake

# * PACKAGE_TYPE
# * PACKAGE_BUCKET

#PACKAGE_TYPE=CORE
#PACKAGE_BUCKET=gs://carto-analytics-toolbox/core/snowflake

PACKAGE_VERSION=$(date +%Y.%m.%d)

echo "Releasing installation package "$PACKAGE_VERSION" in $PACKAGE_BUCKET"

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
export CLOUD=snowflake
export GIT_DIFF=off
for module in `node ${SCRIPTS_DIR}/modulesort.js`; do
    echo -e "\n> Module $module/$CLOUD"
    make -C $ROOT_DIR/modules/$module/$CLOUD serialize-module \
        PACKAGE_VERSION=$PACKAGE_VERSION VERSION_FUNCTION=VERSION_$PACKAGE_TYPE || exit 1
    cat $ROOT_DIR/modules/$module/$CLOUD/dist/module.sql >> $DIST_DIR/modules.sql
    rm -f $ROOT_DIR/modules/$module/$CLOUD/dist/module.sql
done

if [ -n ${MAKE_RELEASE} ];
then
    # Upload the package to the bucket
    gsutil -h "Content-Type:text/plain" cp $DIST_DIR/version $PACKAGE_BUCKET/latest/
    gsutil -h "Content-Type:application/sql" cp $DIST_DIR/modules.sql $PACKAGE_BUCKET/latest/
    gsutil -h "Content-Type:text/plain" cp $DIST_DIR/version $PACKAGE_BUCKET/$PACKAGE_VERSION/
    gsutil -h "Content-Type:application/sql" cp $DIST_DIR/modules.sql $PACKAGE_BUCKET/$PACKAGE_VERSION/
fi
