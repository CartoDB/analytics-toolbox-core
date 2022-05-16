# Makefile for BigQuery modules

CLOUD = bigquery

ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

LIB_DIR = $(ROOT_DIR)/lib
DIST_DIR = $(ROOT_DIR)/dist
ENV_DIR ?= $(ROOT_DIR)/../../..
LINT_DIR ?= $(ROOT_DIR)/../../..
COMMON_DIR ?= $(ROOT_DIR)/../../../common/$(CLOUD)
SCRIPTS_DIR ?= $(ROOT_DIR)/../../../scripts
SHARED_DIR = $(ROOT_DIR)/../shared/javascript

ifneq (,$(wildcard $(ENV_DIR)/.env))
	include $(ENV_DIR)/.env
	export $(shell sed 's/=.*//' $(ENV_DIR)/.env)
endif

SED = sed
GSUTIL = gsutil
BQ = bq --location=$(BQ_REGION) --project_id=$(BQ_PROJECT)

BQ_MODULE_LABEL ?= spatial_extension_module:core
BQ_DEPLOY_DATASET ?= $(BQ_DATASET_PREFIX)carto
BQ_PREFIX = $(BQ_PROJECT).$(BQ_DATASET_PREFIX)

PACKAGE_TYPE ?= CORE
PACKAGE_VERSION ?= dev
VERSION_FUNCTION = VERSION_$(PACKAGE_TYPE)

BQ_BUCKET ?= gs://<BUCKET>/
BQ_LIBRARY = $(DIST_DIR)/index.js
BQ_LIBRARY_BUCKET = $(BQ_BUCKET)$(BQ_DEPLOY_DATASET)/libs/$(MODULE)Lib.js

NODE_MODULES = $(ROOT_DIR)/node_modules
NODE_MODULES_DEV = $(COMMON_DIR)/node_modules
NODE_MODULES_SHARED = $(SHARED_DIR)/node_modules

MODULE_PERMISSIONS_BASH ?= set_module_permissions.sh

REPLACEMENTS_COMMON = -e 's!@@BQ_LIBRARY_BUCKET@@!$(BQ_LIBRARY_BUCKET)!g' -e 's!@@BQ_PROJECT@@!$(BQ_PROJECT)!g' -e 's!@@BQ_DATASET_PREFIX@@!$(BQ_DATASET_PREFIX)!g' \
                      -e 's!@@BQ_REGION@@!$(BQ_REGION)!g' -e 's!@@BQ_PACKAGE_VERSION@@!$(PACKAGE_VERSION)!g' -e 's!@@BQ_VERSION_FUNCTION@@!$(VERSION_FUNCTION)!g' $(REPLACEMENTS_EXTRA)
REPLACEMENTS = -e 's!@@BQ_PREFIX@@!$(BQ_PREFIX)!g' $(REPLACEMENTS_COMMON)
REPLACEMENTS_PKG = -e 's!@@BQ_PREFIX@@!$(BQ_DATASET_PREFIX)!g' $(REPLACEMENTS_COMMON)

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
	$(POST_BUILD)
endif
ifdef MAKE_LIB
	$(MAKE) -C $(LIB_DIR) build
endif

test-unit:
	UNIT_TEST=1 \
	$(MAKE) build
	PATH=$(NODE_MODULES_DEV)/.bin/:$(PATH) \
	jest test/unit/$(TEST) --testTimeout=30000
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
	GOOGLE_APPLICATION_CREDENTIALS=$(GOOGLE_APPLICATION_CREDENTIALS) \
	jest test/integration/$(TEST) --testTimeout=120000 $(TEST_INTEGRATION_EXTRA)
endif
ifdef MAKE_LIB
ifndef TEST
	GOOGLE_APPLICATION_CREDENTIALS=$(GOOGLE_APPLICATION_CREDENTIALS) \
	$(MAKE) -C test/integration-old/ test-integration TEST_OLD=$(TEST_OLD)
endif
endif

deploy: check
ifdef MODULE_DEPS
	if [ "$(DEPLOY_DEPS)" = "1" ]; then \
		for module_dep in $(MODULE_DEPS); do \
			$(MAKE) -C $(MODULE_DEPS_DIR)/modules/$$module_dep/$(CLOUD) deploy || exit 1; \
		done \
	fi;
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
	if [ "$(DEPLOY_DEPS)" = "1" ]; then \
		for module_dep in $(MODULE_DEPS); do \
			$(MAKE) -C $(MODULE_DEPS_DIR)/modules/$$module_dep/$(CLOUD) clean-deploy || exit 1; \
		done \
	fi;
endif
	$(MAKE) storage-remove
	$(MAKE) dataset-remove || ((sleep 5 && $(MAKE) dataset-remove) || exit 1)

storage-upload:
	$(MAKE) build
	$(GSUTIL) cp -r $(BQ_LIBRARY) $(BQ_LIBRARY_BUCKET)

storage-remove:
	if [ `$(GSUTIL) ls $(BQ_LIBRARY_BUCKET) 2>&1 | grep "$(BQ_LIBRARY_BUCKET)"` ]; then \
		$(GSUTIL) rm -r -f $(BQ_LIBRARY_BUCKET); \
	fi

dataset-create:
	$(BQ) show $(BQ_DEPLOY_DATASET) 2>/dev/null 1>/dev/null || \
		$(BQ) mk -d --description "$(BQ_DEPLOY_DATASET) module" -label $(BQ_MODULE_LABEL) $(BQ_DEPLOY_DATASET)
	$(MAKE) post-dataset-create

post-dataset-create:

dataset-remove:
	$(BQ) rm -r -f -d $(BQ_DEPLOY_DATASET)

dataset-deploy:
	for n in `CLOUD=$(CLOUD) node $(SCRIPTS_DIR)/sqlsort.js`; do \
		echo Deploying $$n; \
		$(SED) $(REPLACEMENTS) $$n | $(BQ) query -q --format=json --use_legacy_sql=false --project_id=$(BQ_PROJECT) --dataset_id=$(BQ_DEPLOY_DATASET) || exit 1; \
	done
	$(SED) $(REPLACEMENTS) $(COMMON_DIR)/VERSION.sql | $(BQ) query -q --format=json --use_legacy_sql=false --project_id=$(BQ_PROJECT) --dataset_id=$(BQ_DEPLOY_DATASET) || exit 1

serialize-module:: build
	rm -f $(DIST_DIR)/module.sql
	rm -f $(DIST_DIR)/module-header.sql
	rm -f $(DIST_DIR)/module-footer.sql
	touch $(DIST_DIR)/module-header.sql
	if [ "$(PACKAGE_TYPE)" = "CORE" ]; then \
		$(SED) $(REPLACEMENTS_PKG) $(COMMON_DIR)/DROP_FUNCTIONS.sql >> $(DIST_DIR)/module-header.sql; \
	fi
	for n in `CLOUD=$(CLOUD) node $(SCRIPTS_DIR)/sqlsort.js`; do \
	  	$(SED) $(REPLACEMENTS_PKG) $$n >> $(DIST_DIR)/module.sql; \
		echo "" >> $(DIST_DIR)/module.sql; \
	done
	$(SED) $(REPLACEMENTS_PKG) $(COMMON_DIR)/VERSION.sql >> $(DIST_DIR)/module-footer.sql;

serialize-functions:
	mkdir -p $(DIST_DIR)
	rm -f $(DIST_DIR)/funct_names.csv
	MODULE=$(MODULE) node $(SCRIPTS_DIR)/sqlfunctions.js >> $(DIST_DIR)/funct_names.csv

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