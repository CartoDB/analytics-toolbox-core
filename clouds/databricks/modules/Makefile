# Makefile modules for Databricks

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

ENV_DIR ?= $(ROOT_DIR)/..
TEST_DIR ?= $(ROOT_DIR)/test
SQL_DIR ?= $(ROOT_DIR)/sql
SQL_DIRS += $(ROOT_DIR)/sql
COMMON_DIR = $(ROOT_DIR)/../common
BUILD_DIR ?= $(ROOT_DIR)/build
export DB_VERSION_FUNCTION ?= VERSION_CORE

include $(COMMON_DIR)/Makefile

.SILENT:

.PHONY: help lint build deploy test remove clean

help:
	echo "Available targets: help lint build deploy test remove clean"

lint: venv3 $(NODE_MODULES_DEV)
	echo "Linting modules..."
	echo "- Lint Markdown files"
	PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
	markdownlint -f '**/*.md' --ignore **/node_modules/** --disable MD013 MD024 MD033 MD036 MD040 MD041 MD051 MD045 --
	echo "- Lint SQL files"
	$(VENV3_BIN)/python $(COMMON_DIR)/sql_lint.py "$(wildcard $(SQL_DIR)/**/*.sql)" $(COMMON_DIR)/.sqlfluff "$(wildcard $(SQL_DIR)/.sqlfluffignore)" || exit 1
	echo "- Lint Python files"
	$(VENV3_BIN)/brunette test --line-length=88 --single-quotes --quiet
	$(VENV3_BIN)/flake8 test --max-line-length=88 --enable-extensions Q0 --ignore=D100,D101,D102,D103,D104,D105,D106,D107,W503,E203,E501

build: venv3
	echo "Building modules..."
	$(VENV3_BIN)/python  $(COMMON_DIR)/create_modules_sql.py "$(SQL_DIRS)" $(BUILD_DIR)/modules.sql $(DB_SCHEMA)

deploy: check build
	echo "Deploying modules..."
	$(VENV3_BIN)/python $(COMMON_DIR)/run_query.py "CREATE SCHEMA IF NOT EXISTS $(DB_SCHEMA);"
	$(VENV3_BIN)/python $(COMMON_DIR)/run_script.py $(BUILD_DIR)/modules.sql
	$(MAKE) extra-deploy

extra-deploy::

test: check venv3
	echo "Testing modules..."
	. $(VENV3_DIR)/bin/activate && \
	for module in `ls $(TEST_DIR)`; do \
		echo "> Module $${module}"; \
		pytest -rP -p no:warnings -vv $(TEST_DIR)/$${module} || exit 1; \
	done; \
	deactivate

remove: venv3
	echo "Removing modules..."
	$(VENV3_BIN)/python $(COMMON_DIR)/run_query.py "DROP SCHEMA IF EXISTS $(DB_SCHEMA) CASCADE;"

clean:
	echo "Cleaning modules..."
	rm -rf $(BUILD_DIR) $(VENV3_DIR) $(NODE_MODULES_DEV)
