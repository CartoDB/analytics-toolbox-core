# Makefile modules for Snowflake

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

ENV_DIR ?= $(ROOT_DIR)/..
BUILD_DIR ?= $(ROOT_DIR)/build
COMMON_DIR ?= $(ROOT_DIR)/../common

MODULES_DIRS ?= .
export VERSION_FUNCTION ?= VERSION_CORE
export PACKAGE_VERSION ?= $(shell cat $(ROOT_DIR)/../version)

REPLACEMENTS = "SF_SCHEMA VERSION_FUNCTION PACKAGE_VERSION"

# TODO: Autodetect
REPLACEMENTS_LIBS = "SF_LIBRARY_QUADBIN"
export SF_LIBRARY_QUADBIN = $(shell cat $(ROOT_DIR)/../libraries/javascript/build/quadbin.js)

include $(COMMON_DIR)/Makefile

.SILENT:

.PHONY: help lint build deploy test remove clean

help:
	echo "Available targets: lint build deploy test remove clean"

lint:
	echo "Linting modules..."
	echo "No action"

build:
	echo "Building modules..."
	rm -rf $(BUILD_DIR)
	mkdir $(BUILD_DIR)
	REPLACEMENTS=$(REPLACEMENTS)" "$(REPLACEMENTS_LIBS)" "$(REPLACEMENTS_EXTRA) \
	$(COMMON_DIR)/build_modules.js $(MODULES_DIRS) --output=$(BUILD_DIR) --diff=$(diff) --modules=$(modules) --functions=$(functions) --production=$(production)

deploy: check build
	echo "Deploying modules..."
	$(COMMON_DIR)/run-query.js "CREATE SCHEMA IF NOT EXISTS $(SF_SCHEMA);"
	$(COMMON_DIR)/run-script.js $(BUILD_DIR)/modules.sql

test: check $(NODE_MODULES_DEV)
	echo "Testing modules..."
	SF_SCHEMA=$(SF_SCHEMA) \
	PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
	jest --testTimeout=40000 $(shell $(COMMON_DIR)/list_functions.js --diff=$(diff) --modules=$(modules) --functions=$(functions))

remove: check venv3
	echo "Removing modules..."
	$(COMMON_DIR)/run-query.js "DROP SCHEMA IF EXISTS $(SF_SCHEMA) CASCADE;"

clean:
	echo "Cleaning modules..."
	rm -rf $(BUILD_DIR) $(VENV3_DIR) $(NODE_MODULES_DEV)
