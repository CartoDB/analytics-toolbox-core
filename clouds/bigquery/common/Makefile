# Makefile common for Bigquery

PYTHON3_VERSION = 3
VENV3_DIR ?= $(COMMON_DIR)/../venv3
VENV3_BIN = $(VENV3_DIR)/bin
GSUTIL = gsutil
NODE_MODULES_DEV = $(COMMON_DIR)/node_modules
BQ = bq --location=$(BQ_REGION) --project_id=$(BQ_PROJECT)
BQ_DATASET_DEFAULT = carto
BQ_LIBRARY_DEFAULT ?= carto_analytics_toolbox_core

ifeq ($(production),1)
export BQ_LIBRARY_BUCKET = $(BQ_BUCKET)/$(BQ_DATASET_DEFAULT)/libs/$(BQ_LIBRARY_DEFAULT).js
export BQ_LIBRARY_TILER_BUCKET = $(BQ_BUCKET)/$(BQ_DATASET_DEFAULT)/libs/$(BQ_LIBRARY_DEFAULT)_tiler.js
else
export BQ_LIBRARY_BUCKET = $(BQ_BUCKET)/$(BQ_PREFIX)$(BQ_DATASET_DEFAULT)/libs/$(BQ_LIBRARY_DEFAULT).js
export BQ_LIBRARY_TILER_BUCKET = $(BQ_BUCKET)/$(BQ_PREFIX)$(BQ_DATASET_DEFAULT)/libs/$(BQ_LIBRARY_DEFAULT)_tiler.js

endif

ifneq (,$(wildcard $(ENV_DIR)/.env))
    include $(ENV_DIR)/.env
	export $(shell sed 's/=.*//' $(ENV_DIR)/.env)
endif

ifeq ($(production),1)
export BQ_DATASET = $(BQ_DATASET_DEFAULT)
else
export BQ_DATASET = $(BQ_PROJECT).$(BQ_PREFIX)$(BQ_DATASET_DEFAULT)
endif

.PHONY: check venv3

check:
ifndef BQ_PROJECT
	$(error BQ_PROJECT is undefined)
endif
ifndef BQ_BUCKET
	$(error BQ_BUCKET is undefined)
endif
ifndef BQ_REGION
	$(error BQ_REGION is undefined)
endif
ifeq ($(shell echo "$(BQ_BUCKET)" | grep -E "^gs://(.+)[^/]$$"),)
	$(error BQ_BUCKET is not valid. Must be: gs://<bucket> or gs://<bucket>/<folder>)
endif

venv3:
	virtualenv -p python$(PYTHON3_VERSION) $(VENV3_DIR) -q
	$(VENV3_BIN)/pip install --upgrade pip -q && \
	$(VENV3_BIN)/pip install -r $(COMMON_DIR)/python3_requirements.txt -q

$(NODE_MODULES_DEV):
	yarn -s --update-checksums --cwd $(COMMON_DIR)
