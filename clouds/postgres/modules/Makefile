# Makefile modules for Postgres

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

ENV_DIR ?= $(ROOT_DIR)/..
BUILD_DIR ?= $(ROOT_DIR)/build
COMMON_DIR ?= $(ROOT_DIR)/../common

MODULES_DIRS ?= .
export VERSION_FUNCTION ?= VERSION_CORE
export PACKAGE_VERSION ?= $(shell cat $(ROOT_DIR)/../version)

REPLACEMENTS = "PG_SCHEMA PG_LIBRARY VERSION_FUNCTION PACKAGE_VERSION"

include $(COMMON_DIR)/Makefile

.SILENT:

.PHONY: help lint build deploy test remove clean

help:
	echo "Available targets: lint build deploy test remove clean"

lint: venv3
	echo "Linting modules..."
	$(VENV3_BIN)/brunette test --line-length=88 --single-quotes --quiet
	$(VENV3_BIN)/flake8 test --enable-extensions Q0 --ignore=D100,D101,D102,D103,D104,D105,D106,D107,W503

build: $(NODE_MODULES_DEV)
	echo "Building modules..."
	rm -rf $(BUILD_DIR)
	mkdir $(BUILD_DIR)
	REPLACEMENTS=$(REPLACEMENTS)" "$(REPLACEMENTS_EXTRA) \
	$(COMMON_DIR)/build_modules.js ${MODULES_DIRS} --output=$(BUILD_DIR) --diff=$(diff) --modules=$(modules) --functions=$(functions) --production=$(production)

deploy: check venv3 build
	echo "Deploying modules..."
	$(VENV3_BIN)/python $(COMMON_DIR)/run_query.py "CREATE SCHEMA IF NOT EXISTS $(PG_SCHEMA);"
	$(VENV3_BIN)/python $(COMMON_DIR)/run_script.py $(BUILD_DIR)/modules.sql

test: check venv3 $(NODE_MODULES_DEV)
	echo "Testing modules..."
	$(VENV3_BIN)/pytest -rP -p no:warnings -x -vv $(shell $(COMMON_DIR)/list_functions.js --diff=$(diff) --modules=$(modules) --functions=$(functions))

remove: venv3
	echo "Removing modules..."
	$(VENV3_BIN)/python $(COMMON_DIR)/run_query.py "DROP SCHEMA IF EXISTS $(PG_SCHEMA) CASCADE;"

clean:
	echo "Cleaning modules..."
	rm -rf $(BUILD_DIR) $(VENV3_DIR) $(NODE_MODULES_DEV)
