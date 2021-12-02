# Makefile for BigQuery modules

CLOUD = bigquery

SED = sed
GSUTIL = gsutil
BQ = bq --location=$(BQ_REGION) --project_id=$(BQ_PROJECT)

BQ_MODULE_LABEL ?= spatial_extension_module:core
BQ_DEPLOY_DATASET = $(BQ_DATASET_PREFIX)carto
BQ_DATASET = $(BQ_DATASET_PREFIX)$(MODULE)
BQ_PREFIX = $(BQ_PROJECT).$(BQ_DATASET_PREFIX)

ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

LIB_DIR = $(ROOT_DIR)/lib
DIST_DIR = $(ROOT_DIR)/dist
BQ_LIBRARY = $(DIST_DIR)/index.js
BQ_BUCKET_PATH = $(BQ_BUCKET)$(BQ_DATASET)/
BQ_LIBRARY_BUCKET = $(BQ_BUCKET_PATH)index.js

LINT_DIR ?= $(ROOT_DIR)/../../..
COMMON_DIR ?= $(ROOT_DIR)/../../../common/bigquery
SCRIPTS_DIR ?= $(ROOT_DIR)/../../../scripts
SHARED_DIR = $(ROOT_DIR)/../shared/javascript

NODE_MODULES = $(ROOT_DIR)/node_modules
NODE_MODULES_DEV = $(COMMON_DIR)/node_modules
NODE_MODULES_SHARED = $(SHARED_DIR)/node_modules

MODULE_PERMISSIONS_BASH ?= set_module_permissions.sh

REPLACEMENTS = -e 's!@@BQ_PREFIX@@!$(BQ_PREFIX)!g' -e 's!@@BQ_LIBRARY_BUCKET@@!$(BQ_LIBRARY_BUCKET)!g' -e 's!@@BQ_PROJECT@@!$(BQ_PROJECT)!g' -e 's!@@BQ_DATASET_PREFIX@@!$(BQ_DATASET_PREFIX)!g' -e 's!@@BQ_REGION@@!$(BQ_REGION)!g' $(REPLACEMENTS_EXTRA)

.SILENT:

.PHONY: help lint lint-fix install build test-unit test-integration test-integration-full deploy clean clean-deploy serialize-module serialize-functions

help:
	echo "Please choose one of the following targets: lint, lint-fix, install, build, test-unit, test-integration, test-integration-full, deploy, clean, clean-deploy, serialize-module, serialize-functions"

$(NODE_MODULES):
	yarn -s --update-checksums

$(NODE_MODULES_DEV):
	yarn -s --update-checksums --cwd $(COMMON_DIR)

$(NODE_MODULES_SHARED):
	if [ -d ${SHARED_DIR} ]; then \
		yarn -s --update-checksums --cwd $(SHARED_DIR); \
	fi

lint: $(NODE_MODULES_DEV)
	PATH=$(NODE_MODULES_DEV)/.bin/:$(PATH) \
	eslint --config $(LINT_DIR)/.eslintrc.js .
ifdef MAKE_LIB
	$(MAKE) -C $(LIB_DIR) lint
endif

lint-fix: $(NODE_MODULES_DEV)
	PATH=$(NODE_MODULES_DEV)/.bin/:$(PATH) \
	eslint --config $(LINT_DIR)/.eslintrc.js . --fix
ifdef MAKE_LIB
	$(MAKE) -C $(LIB_DIR) lint-fix
endif

install: $(NODE_MODULES) $(NODE_MODULES_SHARED) $(NODE_MODULES_DEV)

build: install
ifndef NO_BUILD
	NAME=$(MODULE)Lib \
	PATH=$(NODE_MODULES_DEV)/.bin/:$(PATH) \
	rollup --config $(COMMON_DIR)/rollup.config.js $(BUILD_PARAMS)
endif
ifdef MAKE_LIB
	$(MAKE) -C $(LIB_DIR) build
endif

test-unit:
	UNIT_TEST=1 \
	$(MAKE) build
	PATH=$(NODE_MODULES_DEV)/.bin/:$(PATH) \
	jest test/unit --testTimeout=30000
ifdef MAKE_LIB
	$(MAKE) -C test/unit-old/ test-unit
endif

test-integration-full:
	$(MAKE) deploy
	$(MAKE) test-integration || ($(MAKE) clean-deploy && exit 1)
	$(MAKE) clean-deploy

test-integration: check $(NODE_MODULES_DEV)
ifndef TEST_OLD
	PATH=$(NODE_MODULES_DEV)/.bin/:$(PATH) \
	jest test/integration/$(TEST) --testTimeout=30000 $(TEST_INTEGRATION_EXTRA)
endif
ifdef MAKE_LIB
ifndef TEST
	$(MAKE) -C test/integration-old/ test-integration TEST_OLD=$(TEST_OLD)
endif
endif

deploy: check
ifdef MODULE_DEPS
	for module_dep in $(MODULE_DEPS); do \
		$(MAKE) -C $(MODULE_DEPS_DIR)/modules/$$module_dep/bigquery deploy || exit 1; \
	done
endif
	$(MAKE) storage-upload
	$(MAKE) dataset-create
	$(MAKE) dataset-deploy
ifdef BQ_PERMISSIONS
	BQ_PERMISSIONS_TARGET_DATASET=$(BQ_DEPLOY_DATASET) $(COMMON_DIR)/$(MODULE_PERMISSIONS_BASH)
endif
ifdef BQ_PERMISSIONS_GROUP
	BQ_PERMISSIONS_TARGET_DATASET=$(BQ_DEPLOY_DATASET) $(COMMON_DIR)/set_module_permissions_group.sh
endif

clean:
	rm -rf $(DIST_DIR) $(NODE_MODULES) $(NODE_MODULES_SHARED) $(NODE_MODULES_DEV)
	yarn -s cache clean
ifdef MAKE_LIB
	$(MAKE) -C $(LIB_DIR) clean
	$(MAKE) -C test/unit-old/ clean
endif

clean-deploy: check
ifdef MODULE_DEPS
	for module_dep in $(MODULE_DEPS); do \
		$(MAKE) -C $(MODULE_DEPS_DIR)/modules/$$module_dep/bigquery clean-deploy || exit 1; \
	done
endif
	$(MAKE) storage-remove
	$(MAKE) dataset-remove || ((sleep 5 && $(MAKE) dataset-remove) || exit 1)

storage-upload:
	$(MAKE) build
	$(GSUTIL) cp -r $(BQ_LIBRARY) $(BQ_BUCKET_PATH)

storage-remove:
	if [ `$(GSUTIL) ls $(BQ_BUCKET_PATH) 2>&1 | grep "$(BQ_BUCKET_PATH)"` ]; then \
		$(GSUTIL) rm -r -f $(BQ_BUCKET_PATH); \
	fi

dataset-create:
	$(BQ) show $(BQ_DEPLOY_DATASET) 2>/dev/null 1>/dev/null || \
		$(BQ) mk -d --description "$(BQ_DEPLOY_DATASET) module" -label $(BQ_MODULE_LABEL) $(BQ_DEPLOY_DATASET)
ifdef BQ_CONNECTION_SPATIAL_CATALOG
	if [ "$(MODULE)" = "data" ]; then \
		$(COMMON_DIR)/sync_spatial_catalog.sh; \
	fi
else ifdef BQ_BUCKET_SPATIAL_CATALOG
	if [ "$(MODULE)" = "data" ]; then \
		$(BQ) load --source_format=CSV --skip_leading_rows=1 --allow_quoted_newlines --replace $(BQ_DEPLOY_DATASET).spatial_catalog_datasets $(BQ_BUCKET_SPATIAL_CATALOG)spatial_catalog_datasets.csv \
			dataset_id:string,dataset_slug:string,dataset_name:string,dataset_country:string,dataset_category:string,dataset_provider:string,dataset_version:string,dataset_geom_type:string,dataset_is_public:boolean,dataset_is_product:boolean,associated_geography_id:string; \
		$(BQ) load --source_format=CSV --skip_leading_rows=1 --allow_quoted_newlines --replace $(BQ_DEPLOY_DATASET).spatial_catalog_variables $(BQ_BUCKET_SPATIAL_CATALOG)spatial_catalog_variables.csv \
			variable_slug:string,variable_name:string,variable_description:string,variable_type:string,variable_aggregation:string,dataset_slug:string; \
	fi
endif

dataset-remove:
	$(BQ) rm -r -f -d $(BQ_DEPLOY_DATASET)

dataset-deploy:
	for n in `CLOUD=$(CLOUD) node $(SCRIPTS_DIR)/sqlsort.js`; do \
		echo Deploying $$n; \
		$(SED) $(REPLACEMENTS) $$n | $(BQ) query -q --format=json --use_legacy_sql=false --project_id=$(BQ_PROJECT) --dataset_id=$(BQ_DEPLOY_DATASET) || exit 1; \
	done

serialize-module:
	$(MAKE) build
	rm -f $(DIST_DIR)/module.sql
	echo "CREATE SCHEMA IF NOT EXISTS \`@@BQ_PREFIX@@carto\`;" >> $(DIST_DIR)/module.sql
	for n in `CLOUD=$(CLOUD) node $(SCRIPTS_DIR)/sqlsort.js`; do \
	  	cat $$n >> $(DIST_DIR)/module.sql; \
		echo "" >> $(DIST_DIR)/module.sql; \
	done

serialize-functions:
	mkdir -p $(DIST_DIR)
	rm -f $(DIST_DIR)/funct_names.csv
	MODULE=$(MODULE) QUALIFY=1 FILE_NAME=$${n} node $(SCRIPTS_DIR)/sqlfunctions.js >> $(DIST_DIR)/funct_names.csv

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