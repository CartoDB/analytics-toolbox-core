#!/usr/bin/env bash

# Script to create a list wiht all the functions in the Analytics Toolbox

export CLOUD=snowflake

SCRIPT_DIR=$( dirname "$0" )

$SCRIPT_DIR/../shared/create_functions_list.sh