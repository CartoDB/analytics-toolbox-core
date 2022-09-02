# Makefile modules for Snowflake

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

TEST_DIR ?= $(ROOT_DIR)/test
ENV_DIR ?= $(ROOT_DIR)/..
BUILD_DIR ?= $(ROOT_DIR)/build
ESLINTRC_DIR ?= $(ROOT_DIR)/../../..
COMMON_DIR = $(ROOT_DIR)/../common
LIBS_BUILD_DIR ?= $(ROOT_DIR)/../libraries/javascript/build

MODULES_DIRS ?= $(ROOT_DIR)
export SF_VERSION_FUNCTION ?= VERSION_CORE
ifeq ($(production),1)
export SF_PACKAGE_VERSION ?= $(shell cat $(ROOT_DIR)/../version)
else
export SF_PACKAGE_VERSION ?= $(shell cat $(ROOT_DIR)/../version)-dev
endif
export SF_SHARE ?= $(SF_PREFIX)ANALYTICS_TOOLBOX

REPLACEMENTS = "SF_SCHEMA SF_VERSION_FUNCTION SF_PACKAGE_VERSION SF_SHARE"

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

build-share: $(NODE_MODULES_DEV)
	echo "Building share..."
	rm -rf $(BUILD_DIR)
	mkdir $(BUILD_DIR)
	REPLACEMENTS=$(REPLACEMENTS)" "$(REPLACEMENTS_EXTRA) \
	$(COMMON_DIR)/build_share.js $(MODULES_DIRS) \
		--output=$(BUILD_DIR) --libs_build_dir=$(LIBS_BUILD_DIR) --diff=$(diff) \
		--modules=$(modules) --functions=$(functions) --production=$(production) --nodeps=$(nodeps) --dropfirst=$(dropfirst)

deploy: check build
	echo "Deploying modules..."
	$(COMMON_DIR)/run-query.js "CREATE SCHEMA IF NOT EXISTS $(SF_SCHEMA);"
	$(COMMON_DIR)/run-script.js $(BUILD_DIR)/modules.sql

deploy-share: check build-share
	echo "Deploying share..."
	$(COMMON_DIR)/run-query.js "CREATE SHARE IF NOT EXISTS $(SF_SHARE);"
	$(COMMON_DIR)/run-query.js "GRANT USAGE ON DATABASE $(SF_DATABASE) TO SHARE $(SF_SHARE);"
	$(COMMON_DIR)/run-query.js "GRANT USAGE ON SCHEMA $(SF_DATABASE).$(SF_SCHEMA) TO SHARE $(SF_SHARE);"
	$(COMMON_DIR)/run-script.js $(BUILD_DIR)/share.sql

test: check $(NODE_MODULES_DEV)
	echo "Testing modules..."
	for m in $(shell ls $(TEST_DIR)); do \
		TESTS=`$(COMMON_DIR)/list_functions.js $$m --diff=$(diff) --modules=$(modules) --functions=$(functions)`; \
		if [ ! -z "$$TESTS" ]; then \
			PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
			jest --testTimeout=40000 --bail --verbose $$TESTS; \
		fi; \
	done;

remove: $(NODE_MODULES_DEV)
	echo "Removing modules..."
	$(COMMON_DIR)/run-query.js "DROP SCHEMA IF EXISTS $(SF_SCHEMA) CASCADE;"

remove-share: $(NODE_MODULES_DEV)
	echo "Removing share..."
	$(COMMON_DIR)/run-query.js "DROP SHARE $(SF_SHARE);"

clean:
	echo "Cleaning modules..."
	rm -rf $(BUILD_DIR) $(NODE_MODULES_DEV)