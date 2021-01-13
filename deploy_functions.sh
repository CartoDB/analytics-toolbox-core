#!/bin/bash

projectid="internal-tp0uk-server-1"
gsbucket="topo-bigquery-jslibs"

#Deploy JS libraries
gsutil cp libs/*  gs://$gsbucket/

#regions where to deploy. default_europe-west2 is there to denote the default wich is europe-west2 and not qualified
regions=( default_eu_west2 )

#create datsets if it does not exist Datasets in all regions
ls sql | sort -z|while read libname; do
  #we iterate over the regions
  for reg in "${regions[@]}"
  do
    #we create the daset with no region for backwards compatibility
    if [[ "$reg" == "default_eu_west2" ]];
    then
      region="europe-west2"
      datasetname="$libname"
    else
      region="$reg"
      datasetname="${reg}_${libname}"
    fi

    #create the dataset
    bq --project_id="$projectid" --location="$region" mk -d \
    --description "Dataset in ${region} for functions of library: ${libname}" \
    "$datasetname"

    #To add allAuthenticatedUsers to the dataset we grab the just created permission
    bq --project_id="$projectid" show --format=prettyjson \
    $projectid:"$datasetname" > permissions.json
  
    #add the permision to temp file
    sed  '/"access": \[/a \ 
    {"role": "READER","specialGroup": "allAuthenticatedUsers"},' permissions.json > updated_permission.json

    #we update with the new permissions file
    bq --project_id="$projectid" update --source updated_permission.json $projectid:"$datasetname"

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
    if [[ "$reg" == "default_eu_west2" ]];
    then
      datasetname="${libname}"
    else
      datasetname="${reg}_${libname}"
    fi
    
    #strings to match
    search="jslibs.${libname}.${function_name}"
    replace="\`${projectid}\`.${datasetname}.${function_name}"

    search1="bigquery-jslibs"
    replace1="${gsbucket}"

    search2="jslibs\."
    replace2="\`${projectid}\`."

    echo "CREATING OR UPDATING ${replace}"

    sed "s/\`//g; s/${search}/${replace}/g; s/${search1}/${replace1}/g; s/${search2}/${replace2}/g" $fname > tmp.file
    bq  --project_id="${projectid}" query --use_legacy_sql=false --flagfile=tmp.file
    rm tmp.file

  done
done

