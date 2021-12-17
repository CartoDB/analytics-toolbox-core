#!/usr/bin/env bash
# Copyright (C) 2021 CARTO
# Script to install the Spatial Extension

[[ $TARGET_PROJECT = "" ]] && echo "TARGET_PROJECT is undefined. Run 'export TARGET_PROJECT=<target-project>'" && exit 1
[[ $TARGET_REGION = "" ]] && echo "TARGET_REGION is undefined. Run 'export TARGET_REGION=<target-region>'" && exit 1
[[ $TARGET_BUCKET = "" ]] && echo "TARGET_BUCKET is undefined. Run 'export TARGET_BUCKET=gs://<target-bucket>'" && exit 1

SCRIPT_DIR=$( dirname "$0" )

BQ="bq --location=$TARGET_REGION --project_id=$TARGET_PROJECT"

echo "Checking project..."
if gcloud projects describe $TARGET_PROJECT > /dev/null; then
    echo "- Project '$TARGET_PROJECT' exists"
else
    echo "* Project '$TARGET_PROJECT' does not exist!"
    exit 1
fi

echo "Checking datasets..."
for dataset in $(ls $SCRIPT_DIR/libs); do
    if $BQ ls --datasets --max_results=10000 2>&1 | grep $dataset > /dev/null; then
        echo "- Dataset '$dataset' exists"
    else
        echo "* Dataset '$dataset' does not exist!"
    fi
done

read -p "Do you want to continue with the installation? [ENTER]" -n 1 -r

# Perform the variables replacement
sed -e "s!@@BQ_PREFIX@@!$TARGET_PROJECT.!g" -e "s!@@BQ_LIBRARY_BUCKET@@!$TARGET_BUCKET!g" \
$SCRIPT_DIR/modules.sql > $SCRIPT_DIR/modules_rep.sql

# Deploy the data module tables
if [[ -d "$SCRIPT_DIR/tables/data" ]]; then
    $BQ show data >/dev/null || $BQ mk --dataset data
    for table in $(ls $SCRIPT_DIR/tables/data); do
        $BQ load --source_format=CSV --skip_leading_rows=1 --allow_quoted_newlines --replace \
        data.${table%.*} $SCRIPT_DIR/tables/data/${table%.*}.csv $SCRIPT_DIR/schemas/data/${table%.*}.json
    done
fi

# Deploy the JS libs into the bucket
gsutil -m cp -r $SCRIPT_DIR/libs/ $TARGET_BUCKET/

# Deploy the SQL code
$BQ query --use_legacy_sql=false --max_statement_results=10000 --format=prettyjson < $SCRIPT_DIR/modules_rep.sql
rm $SCRIPT_DIR/modules_rep.sql
