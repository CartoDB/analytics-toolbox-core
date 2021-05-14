#!/usr/bin/env bash

# Script to create a project and needed resources to deploy a
# temporary spatial-extension staging environment in BigQuery

set -e

GOOGLE_CI_FOLDER=571319100622
GOOGLE_BILLING_ACCOUNT=014EAC-6BDFC0-233D1F

# Create project
if gcloud projects list --filter $BQ_PROJECT 2>&1 | grep "Listed 0 items" > /dev/null; then
    gcloud projects create $BQ_PROJECT --folder=$GOOGLE_CI_FOLDER  --quiet
else
    echo "Project $BQ_PROJECT already exists"
fi

# Link billing account
gcloud components install beta --quiet
gcloud beta billing projects link $BQ_PROJECT --billing-account=$GOOGLE_BILLING_ACCOUNT --quiet

# Create public bucket
if gsutil ls $BQ_BUCKET_PUBLIC 2>&1 | grep "bucket does not exist" > /dev/null; then
    gsutil mb -l us-east1 -p $BQ_PROJECT $BQ_BUCKET_PUBLIC
else
    echo "Public bucket $BQ_BUCKET_PUBLIC already exists"
fi

# Create private bucket
if gsutil ls $BQ_BUCKET_PRIVATE 2>&1 | grep "bucket does not exist" > /dev/null; then
    gsutil mb -l us-east1 -p $BQ_PROJECT $BQ_BUCKET_PRIVATE
else
    echo "Private bucket $BQ_BUCKET_PRIVATE already exists"
fi