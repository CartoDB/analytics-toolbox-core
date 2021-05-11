#!/usr/bin/env bash

# Script to create a project and needed resources to deploy a
# temporary spatial-extension staging environment in BigQuery

set -e

GOOGLE_CI_FOLDER=571319100622
GOOGLE_BILLING_ACCOUNT=014EAC-6BDFC0-233D1F

if gcloud projects describe $BQ_PROJECT > /dev/null 2>&1; then
    echo "Project $BQ_PROJECT already exists"
else
    gcloud projects create $BQ_PROJECT --folder=$GOOGLE_CI_FOLDER --quiet

    gcloud components install beta --quiet

    gcloud beta billing projects link $BQ_PROJECT --billing-account=$GOOGLE_BILLING_ACCOUNT --quiet

    gsutil mb -l us-east1 -p $BQ_PROJECT $BQ_BUCKET_PUBLIC

    gcloud config set project $BQ_PROJECT --quiet
fi
