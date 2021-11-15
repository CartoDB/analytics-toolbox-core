#!/usr/bin/env bash

# Script to create a Spatial Extension package for Snowflake

PACKAGE_NAME="carto-spatial-extension-snowflake"

echo "Creating installation package $PACKAGE_NAME.zip";

SCRIPT_DIR=$( dirname "$0" )

ROOT_DIR=$SCRIPT_DIR/../..
DIST_DIR=$ROOT_DIR/dist

rm -rf $DIST_DIR

# Generate modules
$SCRIPT_DIR/serialize_modules.sh $ROOT_DIR $DIST_DIR