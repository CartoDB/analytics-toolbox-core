# Makefile modules for Biguqery

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

TEST_DIR ?= $(ROOT_DIR)/test
ENV_DIR ?= $(ROOT_DIR)/..
BUILD_DIR ?= $(ROOT_DIR)/build
SQL_DIR ?= $(ROOT_DIR)/sql
ESLINTRC_DIR ?= $(ROOT_DIR)/../../..
COMMON_DIR = $(ROOT_DIR)/../common
LIBS_BUILD_DIR ?= $(ROOT_DIR)/../libraries/javascript/build
BQ_DEPLOY_DATASET = $(BQ_PREFIX)$(BQ_DATASET_DEFAULT)

MODULES_DIRS ?= $(ROOT_DIR)
export BQ_VERSION_FUNCTION ?= VERSION_CORE
ifeq ($(production),1)
export BQ_PACKAGE_VERSION ?= $(shell cat $(ROOT_DIR)/../version)
else
export BQ_PACKAGE_VERSION ?= $(shell cat $(ROOT_DIR)/../version)-dev
endif

BQ_MODULE_LABEL ?= spatial_extension_module:core
MODULE_PERMISSIONS_BASH ?= set_module_permissions.sh

REPLACEMENTS = "BQ_DATASET BQ_VERSION_FUNCTION BQ_PACKAGE_VERSION BQ_LIBRARY_BUCKET BQ_PROJECT BQ_REGION"

include $(COMMON_DIR)/Makefile

.SILENT:

.PHONY: help lint build build-share deploy deploy-share test remove remove-share clean

help:
	echo "Available targets: lint build deploy test remove clean"

lint: venv3 $(NODE_MODULES_DEV)
	echo "Linting modules..."
	echo "- Lint JavaScript files"
	PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
	eslint --config $(ESLINTRC_DIR)/.eslintrc.js $(TEST_DIR) --fix
	echo "- Lint Markdown files"
	PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
	markdownlint -f '**/*.md' --ignore **/node_modules/** --disable MD013 MD024 MD033 MD036 MD040 MD041 MD051 --
	echo "- Lint SQL files"
	$(VENV3_BIN)/python $(COMMON_DIR)/sql_lint.py "$(wildcard $(SQL_DIR)/**/*.sql)" $(COMMON_DIR)/.sqlfluff "$(wildcard $(SQL_DIR)/.sqlfluffignore)" || exit 1

build: $(NODE_MODULES_DEV)
	echo "Building modules..."
	rm -rf $(BUILD_DIR)
	mkdir $(BUILD_DIR)
	REPLACEMENTS=$(REPLACEMENTS)" "$(REPLACEMENTS_EXTRA) \
	$(COMMON_DIR)/build_modules.js $(MODULES_DIRS) \
		--output=$(BUILD_DIR) --libs_build_dir=$(LIBS_BUILD_DIR) --diff="$(diff)" \
		--modules=$(modules) --functions=$(functions) --production=$(production) --nodeps=$(nodeps) --dropfirst=$(dropfirst)

deploy: check build
	echo "Deploying modules..."
	$(MAKE) dataset-create
	GOOGLE_APPLICATION_CREDENTIALS=$(GOOGLE_APPLICATION_CREDENTIALS) \
	$(COMMON_DIR)/run-script.js $(BUILD_DIR)/modules.sql
ifdef BQ_PERMISSIONS
	BQ_PERMISSIONS_TARGET_DATASET=$(BQ_DEPLOY_DATASET) $(COMMON_DIR)/$(MODULE_PERMISSIONS_BASH)
endif
ifdef BQ_PERMISSIONS_GROUP
	BQ_PERMISSIONS_TARGET_DATASET=$(BQ_DEPLOY_DATASET) $(COMMON_DIR)/set_module_permissions_group.sh
endif

dataset-create:
	$(BQ) show $(BQ_DEPLOY_DATASET) 2>/dev/null 1>/dev/null || \
		$(BQ) mk -d --description "$(BQ_DEPLOY_DATASET) module" -label $(BQ_MODULE_LABEL) $(BQ_DEPLOY_DATASET)

test: check $(NODE_MODULES_DEV)
	echo "Testing modules..."
	for m in $(shell ls $(TEST_DIR)); do \
		TESTS=`$(COMMON_DIR)/list_functions.js $$m --diff="$(diff)" --modules=$(modules) --functions=$(functions)`; \
		if [ ! -z "$$TESTS" ]; then \
			GOOGLE_APPLICATION_CREDENTIALS=$(GOOGLE_APPLICATION_CREDENTIALS) \
			PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
			jest --testTimeout=150000 --bail --verbose --slowTestThreshold=20 --maxConcurrency=10 $$TESTS \
			     --setupFilesAfterEnv "$(COMMON_DIR)/test-extend.js" || exit 1; \
			OLD_TEST=$(TEST_DIR)/$$m/old-test; \
			if [ -d $$OLD_TEST ]; then \
				echo "Old tests with custon Makefile"; \
				$(MAKE) -C $(TEST_DIR)/$$m/old-test test || exit 1; \
			fi; \
		fi; \
	done;

remove: check
	echo "Removing modules..."
	$(BQ) rm -r -f -d $(BQ_DEPLOY_DATASET)

clean:
	echo "Cleaning modules..."
	rm -rf $(BUILD_DIR) $(NODE_MODULES_DEV)
