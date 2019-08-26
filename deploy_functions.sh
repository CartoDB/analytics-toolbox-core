#!/bin/bash

#Iterate over all SQLs and run them in BQ
find "$(pwd)" -name "*.sql" | sort  -z |while read fname; do
  echo "$fname"
  bq --project_id jslibs query --use_legacy_sql=false --flagfile=$fname
done
