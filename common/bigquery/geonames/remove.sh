#!/bin/bash

# Required variables
# BQ_PROJECT
# BQ_DATASET_PREFIX

#  Remove geocoding tables from the module

bq rm -f -t "${BQ_PROJECT}:${BQ_DATASET_PREFIX}carto.places"
bq rm -f -t "${BQ_PROJECT}:${BQ_DATASET_PREFIX}carto.names"
bq rm -f -t "${BQ_PROJECT}:${BQ_DATASET_PREFIX}carto.words"
