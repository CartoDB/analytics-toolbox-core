#!/bin/bash

#Deploy JS libraries
gsutil cp libs/*  gs://bigquery-jslibs/

#regions where to deploy. default_us is there to denote the default wich is US and not qualified
regions=( eu us default_us )

#create datsets if it does not exist Datasets in all regions
ls sql | sort -z|while read libname; do
  #we iterate over the regions
  for reg in "${regions[@]}"
  do
    #we create the daset with no region for backwards compatibility
    if [[ "$reg" == "default_us" ]];
    then
      region="us"
      datasetname="$libname"
    else
      region="$reg"
      datasetname="${reg}_${libname}"
    fi

    #create the dataset
    bq --location="$region" mk -d \
    --description "Dataset in ${region} for functions of library: ${libname}" \
    "$datasetname"

    #To add allAuthenticatedUsers to the dataset we grab the just created permission
    bq show --format=prettyjson \
    jslibs:"$datasetname" > permissions.json
  
    #add the permision to temp file
    sed  '/"access": \[/a \ 
    {"role": "READER","specialGroup": "allAuthenticatedUsers"},' permissions.json > updated_permission.json

    #we update with the new permissions file
    bq update --source updated_permission.json jslibs:"$datasetname"    

    #cleanup
    rm updated_permission.json
    rm permissions.json
  done
done


#We go over all the SQLs and replace for example jslibs.s2. with jslibs.eu_s2.
#BIT HACKY

#Iterate over all SQLs and run them in BQ
find "$(pwd)" -name "*.sql" | sort  -z |while read fname; do
  echo "$fname"
  DIR=$(dirname "${fname}")
  libname=$(echo $DIR | sed -e 's;.*\/;;')
  file_name=$(basename "${fname}")
  function_name="${file_name%.*}"

  #we iterate over the regions to update or create all functions in the different regions
  for reg in "${regions[@]}"
  do
    if [[ "$reg" == "default_us" ]];
    then
      datasetname="${libname}"
    else
      datasetname="${reg}_${libname}"
    fi
    
    #string to match
    search="jslibs.${libname}.${function_name}"
    replace="jslibs.${datasetname}.${function_name}"

    echo "CREATING OR UPDATING ${replace}"

    sed "s/${search}/${replace}/g" $fname > tmp.file
    bq --project_id jslibs query --use_legacy_sql=false --flagfile=tmp.file
    rm tmp.file

  done
done

