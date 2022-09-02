# Makefile common for Bigquery

BQ_DATASET_DEFAULT ?= carto
NODE_MODULES_DEV = $(COMMON_DIR)/node_modules
GSUTIL = gsutil
BQ = bq --location=$(BQ_REGION) --project_id=$(BQ_PROJECT)
BQ_DEPLOY_DATASET = $(BQ_PREFIX)carto
BQ_LIBRARY_NAME ?= coreLib
export BQ_LIBRARY_BUCKET = $(BQ_BUCKET)$(BQ_DEPLOY_DATASET)/$(BQ_LIBRARY_NAME).js

BQ_MODULE_LABEL ?= spatial_extension_module:core

ifneq (,$(wildcard $(ENV_DIR)/.env))
    include $(ENV_DIR)/.env
	export $(shell sed 's/=.*//' $(ENV_DIR)/.env)
endif

ifeq ($(production),1)
export BQ_DATASET = $(BQ_DATASET_DEFAULT)
else
export BQ_DATASET = $(BQ_PREFIX)$(BQ_DATASET_DEFAULT)
endif

.PHONY: check

check:
ifndef BQ_REGION
	$(error BQ_REGION is undefined)
endif
ifndef BQ_PROJECT
	$(error BQ_PROJECT is undefined)
endif
ifndef BQ_BUCKET
	$(error BQ_BUCKET is undefined)
endif
ifeq ($(shell echo "$(BQ_BUCKET)" | grep -E "^gs://(.+)[/]$$"),)
	$(error BQ_BUCKET is not valid. Must be: gs://<bucket>/ or gs://<bucket>/<folder>/)
endif

$(NODE_MODULES_DEV):
	yarn -s --update-checksums --cwd $(COMMON_DIR)
