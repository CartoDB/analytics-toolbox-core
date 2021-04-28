#!/usr/bin/env bash

# Script to create a project and needed resources to deploy a temporary spatial-extension

set -e


if [ $# -eq 0 ]
  then
    echo "No PR number provided"
    exit 1
fi

GOOGLE_CI_FOLDER=571319100622
GOOGLE_BILLING_ACCOUNT=014EAC-6BDFC0-233D1F

PROJECT_NAME="bqcartost-core-$1"

if gcloud projects describe $PROJECT_NAME > /dev/null 2>&1; then
    echo "Project $PROJECT_NAME already exists"
else
    gcloud projects create $PROJECT_NAME --folder=$GOOGLE_CI_FOLDER  --quiet 
    gcloud components install beta --quiet
    gcloud beta billing projects link $PROJECT_NAME --billing-account=$GOOGLE_BILLING_ACCOUNT --quiet

    gsutil mb -l us-east1 -p $PROJECT_NAME gs://carto-ext-ci-public-$PROJECT_NAME
    gsutil mb -l us-east1 -p $PROJECT_NAME gs://carto-ext-ci-private-$PROJECT_NAME

    gcloud config set project $PROJECT_NAME --quiet 
fi

