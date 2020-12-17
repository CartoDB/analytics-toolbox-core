#!/bin/bash
set -eux

GCP_PROJECT_ID="my-project-name"
GCP_JSLIBS_ID="${GCP_PROJECT_ID}-jslibs"
GCP_JSLIBS_BUCKET="gs://${GCP_JSLIBS_ID}/"

#region to deploy functions
region="eu"

#make the deployment bucket if not exists
gsutil -q stat $GCP_JSLIBS_BUCKET -p $GCP_PROJECT_ID && \
  gsutil mb -c standard -l eu $GCP_JSLIBS_BUCKET -p $GCP_PROJECT_ID  

#deploy the target JS libraries
gsutil cp libs/* $GCP_JSLIBS_BUCKET -p $GCP_PROJECT_ID

#create datasets to host each of the wrapper libraries in sql/
ls sql | sort -z|while read libname; do
  datasetname="$libname"

  #create the dataset if not exists
  bq show "$datasetname" ||  bq --project_id="$GCP_PROJECT_ID" --location="$reg" mk -d \
      --description "Dataset in ${reg} for functions of library: ${libname}" \
      "$datasetname"
done

#deploy the wrapper functions
find "$(pwd)" -name "*.sql" | sort  -z |while read fname; do
  echo "deploying: ${fname}"
  DIR=$(dirname "${fname}")
  libname=$(echo $DIR | sed -e 's;.*\/;;')
  file_name=$(basename "${fname}")
  function_name="${file_name%.*}"

  #update all the references in the js files, eg. jslibs.h3.func_name -> `my-project-name`.h3.func_name
  sed -e "s/bigquery-jslibs/${GCP_JSLIBS_ID}/g" -e "s/jslibs\.${libname}\./\`${GCP_PROJECT_ID}\`.${libname}./g" \
    $fname > tmp1.file

  # deploy the function
  bq  --project_id="${GCP_PROJECT_ID}" --location="$region" query --use_legacy_sql=false --flagfile=tmp1.file
  rm tmp1.file 
done

