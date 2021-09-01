#!/usr/bin/env bash

# Script to create a Spatial Extension package for BigQuery

# * BQ_PROJECT
# * BQ_BUCKET

if [[ ! "$BQ_PROJECT" =~ ^(carto-os)$ ]]; then
    echo "Invalid project $BQ_PROJECT"
    exit 0
fi

PACKAGE_BUCKET="${BQ_BUCKET}bigquery/packages"
PACKAGE_NAME="$BQ_PROJECT-spatial-extension-bigquery"

echo "Creating installation package $PACKAGE_BUCKET/$PACKAGE_NAME.zip"

SCRIPT_DIR=$( dirname "$0" )

ROOT_DIR=$SCRIPT_DIR/../..
DIST_DIR=$ROOT_DIR/dist

rm -rf $DIST_DIR
mkdir -p $DIST_DIR/libs

# Generate core modules
$SCRIPT_DIR/serialize_modules.sh $ROOT_DIR/core $DIST_DIR/core
cat $DIST_DIR/core/modules.sql >> $DIST_DIR/modules.sql
mv $DIST_DIR/core/libs/*/ $DIST_DIR/libs/
rm -rf $DIST_DIR/core

# Generate the package
cp $SCRIPT_DIR/package/README.md $DIST_DIR/
cp $SCRIPT_DIR/package/install_spatial_extension.sh $DIST_DIR/
CWD=$(pwd)
cd $DIST_DIR && zip -r $PACKAGE_NAME.zip * && cd $CWD

# Upload the package to the bucket
gsutil -h "Content-Type:application/zip" cp $DIST_DIR/$PACKAGE_NAME.zip $PACKAGE_BUCKET/
