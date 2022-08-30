# Makefile modules for Snowflake

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

ENV_DIR ?= $(ROOT_DIR)/..
BUILD_DIR ?= $(ROOT_DIR)/build
ESLINTRC_DIR ?= $(ROOT_DIR)/../../..
COMMON_DIR = $(ROOT_DIR)/../common
LIBS_BUILD_DIR ?= $(ROOT_DIR)/../libraries/javascript/build

MODULES_DIRS ?= .
export VERSION_FUNCTION ?= VERSION_CORE
export PACKAGE_VERSION ?= $(shell cat $(ROOT_DIR)/../version)

REPLACEMENTS = "SF_SCHEMA VERSION_FUNCTION PACKAGE_VERSION"

include $(COMMON_DIR)/Makefile

.SILENT:

.PHONY: help lint build deploy test remove clean

help:
	echo "Available targets: lint build deploy test remove clean"

lint: $(NODE_MODULES_DEV)
	echo "Linting modules..."
	PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
	eslint --config $(ESLINTRC_DIR)/.eslintrc.js test --fix

build: $(NODE_MODULES_DEV)
	echo "Building modules..."
	rm -rf $(BUILD_DIR)
	mkdir $(BUILD_DIR)
	REPLACEMENTS=$(REPLACEMENTS)" "$(REPLACEMENTS_EXTRA) \
	$(COMMON_DIR)/build_modules.js $(MODULES_DIRS) \
		--output=$(BUILD_DIR) --libs_build_dir=$(LIBS_BUILD_DIR) --diff=$(diff) \
		--modules=$(modules) --functions=$(functions) --production=$(production) --nodeps=$(nodeps)

build-libraries:
	$(MAKE) -C ../libraries/javascript build

deploy: check build
	echo "Deploying modules..."
	$(COMMON_DIR)/run-query.js "CREATE SCHEMA IF NOT EXISTS $(SF_SCHEMA);"
	$(COMMON_DIR)/run-script.js $(BUILD_DIR)/modules.sql

test: check $(NODE_MODULES_DEV)
	echo "Testing modules..."
	PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
	jest --testTimeout=40000 --bail --verbose \
		$(shell $(COMMON_DIR)/list_functions.js --diff=$(diff) --modules=$(modules) --functions=$(functions))

remove:
	echo "Removing modules..."
	$(COMMON_DIR)/run-query.js "DROP SCHEMA IF EXISTS $(SF_SCHEMA) CASCADE;"

clean:
	echo "Cleaning modules..."
	rm -rf $(BUILD_DIR) $(NODE_MODULES_DEV)
