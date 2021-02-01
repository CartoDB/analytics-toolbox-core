#!/usr/bin/env bash

if [ -z "$BQ_DATASET_PREFIX" ]
then
      echo "\$BQ_DATASET_PREFIX must be declared"
      return 1
fi

export POST_INTEGRATION_CLEANUP=0
export BQ_PROJECTID="cartodb-gcp-backend-data-team"
export BQ_BUCKET="gs://bqcartodev/"
export BQ_DATASET_SKEL="${BQ_DATASET_PREFIX}_skel"


export ENABLED_BQ=1
