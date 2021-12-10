#!/usr/bin/env bash

# Script to create a Spatial Extension package for BigQuery

# * BQ_PROJECT
# * BQ_BUCKET
# * PACKAGE_TYPE

#PACKAGE_TYPE=CORE

if [[ ! "$BQ_PROJECT" =~ ^(carto-os|carto-st|carto-sm|carto-me|carto-la|carto-un)$ ]]; then
    echo "Invalid project $BQ_PROJECT"
    exit 0
fi

BQ_PROJECT_SUFFIX=${BQ_PROJECT##*-}

PACKAGE_BUCKET="${BQ_BUCKET}bigquery/packages"
PACKAGE_NAME="$BQ_PROJECT-spatial-extension-bigquery"
PACKAGE_VERSION=$(date +%Y.%m.%d)

echo "Creating installation package $PACKAGE_BUCKET/$PACKAGE_NAME.zip"

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
export CLOUD=bigquery
export GIT_DIFF=off
for module in `node ${SCRIPTS_DIR}/modulesort.js`; do
    echo -e "\n> Module $module/$CLOUD"
    make -C $ROOT_DIR/modules/$module/$CLOUD serialize-module \
        PACKAGE_VERSION=$PACKAGE_VERSION VERSION_FUNCTION=VERSION_$PACKAGE_TYPE || exit 1
    sed -e "s!@@BQ_LIBRARY_BUCKET@@!@@BQ_LIBRARY_BUCKET@@/libs/$module/index.js!g" $ROOT_DIR/modules/$module/$CLOUD/dist/module.sql >> $ROOT_DIR/modules/$module/$CLOUD/dist/module_rep.sql
    cat $ROOT_DIR/modules/$module/$CLOUD/dist/module_rep.sql >> $DIST_DIR/modules.sql
    rm -f $ROOT_DIR/modules/$module/$CLOUD/dist/module.sql $ROOT_DIR/modules/$module/$CLOUD/dist/module_rep.sql
    mkdir -p $DIST_DIR/libs
    mkdir -p $DIST_DIR/libs/$module
    cp $ROOT_DIR/modules/$module/$CLOUD/dist/index.js $DIST_DIR/libs/$module/index.js
done

if [ ! -z ${ADD_DATA_MODULE} ];
then
    # Get the data module tables/schemas
    echo "--project_id=$BQ_PROJECT" > $SCRIPT_DIR/.bigqueryrc
    mkdir -p $DIST_DIR/tables/data
    mkdir -p $DIST_DIR/schemas/data
    for table in 'spatial_catalog_datasets' 'spatial_catalog_variables'; do
        bq --bigqueryrc=$SCRIPT_DIR/.bigqueryrc query --use_legacy_sql=false --max_rows=1000000 --format=csv \
        "SELECT * FROM data.$table" > $DIST_DIR/tables/data/$table.csv
        bq --bigqueryrc=$SCRIPT_DIR/.bigqueryrc show --schema \
        "data.$table" > $DIST_DIR/schemas/data/$table.json
    done
    rm $SCRIPT_DIR/.bigqueryrc
fi

# Generate the package
sed -e "s!@@BQ_PROJECT_SUFFIX@@!$BQ_PROJECT_SUFFIX!g" $SCRIPT_DIR/package/README.md >> $DIST_DIR/README.md
cp $SCRIPT_DIR/package/install_spatial_extension.sh $DIST_DIR/
CWD=$(pwd)
cd $DIST_DIR && zip -r $PACKAGE_NAME.zip * && cd $CWD

# Upload the package to the bucket
gsutil -h "Content-Type:application/zip" cp $DIST_DIR/$PACKAGE_NAME.zip $PACKAGE_BUCKET/
