#!/bin/bash
set -eux

alias gsutil=/usr/lib/google-cloud-sdk/platform/gsutil/gsutil

GCP_PROJECT_ID="matthew-jackson"
GCP_BUCKET="gs://${GCP_PROJECT_ID}-jslibs/"

#regions where to deploy. default_us is there to denote the default wich is US and not qualified
regions=( eu )

# make the deployment bucket if not exists
gsutil -q stat $GCP_BUCKET -p $GCP_PROJECT_ID && \
  gsutil mb -c standard -l eu $GCP_BUCKET -p $GCP_PROJECT_ID  

#Deploy JS libraries
gsutil cp libs/* $GCP_BUCKET -p $GCP_PROJECT_ID

#create datsets if it does not exist Datasets in all regions
ls sql | sort -z|while read libname; do
  #we iterate over the regions
  for reg in "${regions[@]}"
  do
    region="eu"
    datasetname="$libname"

    #create the dataset if not exists
    bq show "$datasetname" ||  bq --project_id="$GCP_PROJECT_ID" --location="$reg" mk -d \
        --description "Dataset in ${reg} for functions of library: ${libname}" \
        "$datasetname"
  done
done

# Deploy the SQL wrapper functions to BQ
find "$(pwd)" -name "*.sql" | sort  -z |while read fname; do
  echo "deploying: ${fname}"
  DIR=$(dirname "${fname}")
  libname=$(echo $DIR | sed -e 's;.*\/;;')
  file_name=$(basename "${fname}")
  function_name="${file_name%.*}"

  # Iterate over the regions to update or create all functions in the different regions
  for reg in "${regions[@]}"
  do
  
    # Update all the project references in the js files example jslibs.s2. with jslibs.eu_s2.
    sed -e "s/bigquery-jslibs/${GCP_PROJECT_ID}-jslibs/g" -e "s/jslibs\.${libname}\./\`${GCP_PROJECT_ID}\`.${libname}./g" \
      $fname > tmp1.file

    #cat tmp.file
    #echo "FINDING ERROR: $(grep 'gs://bigquery-`matthew-jackson.eu_h3`-js.umd.js' tmp1.file )"

    # deploy the function
    bq  --project_id="${GCP_PROJECT_ID}" --location="$reg" query --use_legacy_sql=false --flagfile=tmp1.file
    rm tmp1.file 

  done
done

