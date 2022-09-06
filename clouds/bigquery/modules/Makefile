# Makefile modules for Biguqery

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

TEST_DIR ?= $(ROOT_DIR)/test
ENV_DIR ?= $(ROOT_DIR)/..
BUILD_DIR ?= $(ROOT_DIR)/build
ESLINTRC_DIR ?= $(ROOT_DIR)/../../..
COMMON_DIR = $(ROOT_DIR)/../common
LIBS_BUILD_DIR ?= $(ROOT_DIR)/../libraries/javascript/build

MODULES_DIRS ?= $(ROOT_DIR)
export BQ_VERSION_FUNCTION ?= VERSION_CORE
ifeq ($(production),1)
export BQ_PACKAGE_VERSION ?= $(shell cat $(ROOT_DIR)/../version)
else
export BQ_PACKAGE_VERSION ?= $(shell cat $(ROOT_DIR)/../version)-dev
endif

REPLACEMENTS = "BQ_DATASET BQ_VERSION_FUNCTION BQ_PACKAGE_VERSION BQ_LIBRARY_BUCKET"

include $(COMMON_DIR)/Makefile

.SILENT:

.PHONY: help lint build build-share deploy deploy-share test remove remove-share clean

help:
	echo "Available targets: lint build deploy test remove clean"

lint: $(NODE_MODULES_DEV)
	echo "Linting modules..."
	PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
	eslint --config $(ESLINTRC_DIR)/.eslintrc.js $(TEST_DIR) --fix

build: $(NODE_MODULES_DEV)
	echo "Building modules..."
	rm -rf $(BUILD_DIR)
	mkdir $(BUILD_DIR)
	REPLACEMENTS=$(REPLACEMENTS)" "$(REPLACEMENTS_EXTRA) \
	$(COMMON_DIR)/build_modules.js $(MODULES_DIRS) \
		--output=$(BUILD_DIR) --libs_build_dir=$(LIBS_BUILD_DIR) --diff=$(diff) \
		--modules=$(modules) --functions=$(functions) --production=$(production) --nodeps=$(nodeps) --dropfirst=$(dropfirst)

build-libraries:
	$(MAKE) -C ../libraries/javascript build

deploy: check build
	echo "Deploying modules..."
	$(MAKE) dataset-create
	GOOGLE_APPLICATION_CREDENTIALS=$(GOOGLE_APPLICATION_CREDENTIALS) \
	BQ_LIBRARY_BUCKET=$(BQ_LIBRARY_BUCKET) \
	$(COMMON_DIR)/run-script.js $(BUILD_DIR)/modules.sql

dataset-create:
	$(BQ) show $(BQ_DEPLOY_DATASET) 2>/dev/null 1>/dev/null || \
		$(BQ) mk -d --description "$(BQ_DEPLOY_DATASET) module" -label $(BQ_MODULE_LABEL) $(BQ_DEPLOY_DATASET)
	$(MAKE) post-dataset-create

post-dataset-create:

test: check $(NODE_MODULES_DEV)
	echo "Testing modules..."
	for m in $(shell ls $(TEST_DIR)); do \
		TESTS=`$(COMMON_DIR)/list_functions.js $$m --diff=$(diff) --modules=$(modules) --functions=$(functions)`; \
		if [ ! -z "$$TESTS" ]; then \
			GOOGLE_APPLICATION_CREDENTIALS=$(GOOGLE_APPLICATION_CREDENTIALS) \
			PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
			jest --testTimeout=40000 --bail --verbose $$TESTS; \
		fi; \
	done;

remove: $(NODE_MODULES_DEV)
	echo "Removing modules..."
	$(BQ) rm -r -f -d $(BQ_DEPLOY_DATASET)

clean:
	echo "Cleaning modules..."
	rm -rf $(BUILD_DIR) $(NODE_MODULES_DEV)
