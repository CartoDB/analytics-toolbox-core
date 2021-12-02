SCRIPT_DIR=$( dirname "$0" )

for f in $SCRIPT_DIR/spatial_catalog/*.sql; do \
  echo 'Executing ' $f
  sed -e "s!@@BQ_PROJECT@@!$BQ_PROJECT!g" -e "s!@@BQ_CONNECTION_SPATIAL_CATALOG@@!$BQ_CONNECTION_SPATIAL_CATALOG!g" $f | bq query --project_id=$BQ_PROJECT --use_legacy_sql=false
done