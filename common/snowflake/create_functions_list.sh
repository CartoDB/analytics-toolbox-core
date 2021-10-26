#!/usr/bin/env bash

# Script to create a list wiht all the functions in the Analytics Toolbox

PACKAGE_NAME="carto-spatial-extension-snowflake"

echo "Creating installation package funct_names.csv";

SCRIPT_DIR=$( dirname "$0" )

ROOT_DIR=$SCRIPT_DIR/../..
DIST_DIR=$ROOT_DIR/dist

rm -rf $DIST_DIR

# Generate advanced modules
$SCRIPT_DIR/serialize_functions.sh $ROOT_DIR $DIST_DIR/core
cat $DIST_DIR/core/funct_names.csv >> $DIST_DIR/funct_names.csv
rm -rf $DIST_DIR/core
