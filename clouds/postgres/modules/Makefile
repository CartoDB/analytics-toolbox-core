# Makefile modules for Postgres

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

ENV_DIR ?= $(ROOT_DIR)/..
BUILD_DIR ?= $(ROOT_DIR)/build
SQL_DIR ?= $(ROOT_DIR)/sql
COMMON_DIR ?= $(ROOT_DIR)/../common

MODULES_DIRS ?= .
export PG_VERSION_FUNCTION ?= VERSION_CORE
ifeq ($(production),1)
export PG_PACKAGE_VERSION ?= $(shell cat $(ROOT_DIR)/../version)
else
export PG_PACKAGE_VERSION ?= $(shell cat $(ROOT_DIR)/../version)-dev
endif

REPLACEMENTS = "PG_SCHEMA PG_LIBRARY PG_VERSION_FUNCTION PG_PACKAGE_VERSION"

include $(COMMON_DIR)/Makefile

.SILENT:

.PHONY: help lint build deploy test remove remove-functions clean

help:
	echo "Available targets: lint build deploy test remove remove-functions clean"

lint: venv3 $(NODE_MODULES_DEV)
	echo "Linting modules..."
	echo "- Lint Python files"
	$(VENV3_BIN)/brunette test --line-length=88 --single-quotes --quiet
	$(VENV3_BIN)/flake8 test --max-line-length=88 --enable-extensions Q0 --ignore=D100,D101,D102,D103,D104,D105,D106,D107,W503,E203
	echo "- Lint Markdown files"
	PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
	markdownlint -f '**/*.md' --ignore **/node_modules/** --disable MD013 MD024 MD033 MD036 MD040 MD041 MD051 MD045 --
	echo "- Lint SQL files"
	$(VENV3_BIN)/python $(COMMON_DIR)/sql_lint.py "$(wildcard $(SQL_DIR)/**/*.sql)" $(COMMON_DIR)/.sqlfluff "$(wildcard $(SQL_DIR)/.sqlfluffignore)" || exit 1

build: $(NODE_MODULES_DEV)
	echo "Building modules..."
	rm -rf $(BUILD_DIR)
	mkdir $(BUILD_DIR)
	REPLACEMENTS=$(REPLACEMENTS)" "$(REPLACEMENTS_EXTRA) \
	$(COMMON_DIR)/build_modules.js ${MODULES_DIRS} --output=$(BUILD_DIR) \
		--diff="$(diff)" --modules=$(modules) --functions=$(functions) --production=$(production) --dropfirst=$(dropfirst)

deploy: check venv3 build
	echo "Deploying modules..."
	$(VENV3_BIN)/python $(COMMON_DIR)/run_query.py "CREATE SCHEMA IF NOT EXISTS $(PG_SCHEMA);"
	$(VENV3_BIN)/python $(COMMON_DIR)/run_script.py $(BUILD_DIR)/modules.sql
	$(MAKE) extra-deploy

extra-deploy::

test: check venv3 $(NODE_MODULES_DEV)
	echo "Testing modules..."
	if [ ! -z "`$(COMMON_DIR)/list_functions.js --diff="$(diff)" --modules=$(modules) --functions=$(functions)`" ]; then \
		$(VENV3_BIN)/pytest -rP -p no:warnings -x -vv `$(COMMON_DIR)/list_functions.js --diff="$(diff)" --modules=$(modules) --functions=$(functions)`; \
	fi;

remove: venv3
	echo "Removing modules..."
	REPLACEMENTS=$(REPLACEMENTS)" "$(REPLACEMENTS_EXTRA) \
	$(VENV3_BIN)/python $(COMMON_DIR)/run_script.py $(COMMON_DIR)/DROP_FUNCTIONS.sql

remove-functions: venv3
	echo "Removing functions..."
	REPLACEMENTS=$(REPLACEMENTS)" "$(REPLACEMENTS_EXTRA) \
	$(VENV3_BIN)/python $(COMMON_DIR)/run_script.py $(COMMON_DIR)/DROP_FUNCTIONS.sql

clean:
	echo "Cleaning modules..."
	rm -rf $(BUILD_DIR) $(VENV3_DIR) $(NODE_MODULES_DEV)
