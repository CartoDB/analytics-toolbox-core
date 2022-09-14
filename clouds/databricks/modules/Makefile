# Makefile modules for Databricks

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

ENV_DIR ?= $(ROOT_DIR)/..
CLOUD_DIR = $(ROOT_DIR)/..
SQL_DIR ?= $(ROOT_DIR)/sql
COMMON_DIR = $(CLOUD_DIR)/common
SQL_PATH = $(COMMON_DIR)/dropUDF.sql

include $(COMMON_DIR)/Makefile

.SILENT:

.PHONY: help lint test remove

help:
	echo "Available targets: help test remove"

lint: venv3 $(NODE_MODULES_DEV)
	echo "Linting modules..."
	$(VENV3_BIN)/python $(COMMON_DIR)/sql_lint.py "$(wildcard $(SQL_DIR)/*/*.sql)" $(COMMON_DIR)/.sqlfluff
	PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
	markdownlint -f '**/*.md' --disable MD013 MD033 MD036 MD040 MD041 MD051 --

test: check check-extra venv
	echo "Testing modules..."
	. $(COMMON_DIR)/venv/bin/activate && \
	for module in `ls $(ROOT_DIR)/test`; do \
		echo "> Module $${module}"; \
		pytest -rP -p no:warnings -vv $(ROOT_DIR)/test/$${module} || exit 1; \
	done; \
	deactivate

remove: check
	echo "Removing modules..."
	python3 $(COMMON_DIR)/python_utils/create_drop_functions.py
	databricks workspace mkdirs $(SQL_DEPLOY_PATH)
	databricks workspace import --overwrite --language SQL $(SQL_PATH) $(SQL_DEPLOY_PATH)/dropUDF
	$(MAKE) drop-udfs

drop-udfs:
	sed -e 's/@@DB_CLUSTER_ID@@/${DB_CLUSTER_ID}/g' -e 's!@@SQLPath@@!$(SQL_DEPLOY_PATH)/dropUDF!g' $(COMMON_DIR)/submit-run-template.json > $(COMMON_DIR)/submit-run.json
	databricks runs submit --json-file $(COMMON_DIR)/submit-run.json --wait
	echo "- Removing drop script from the workspace"
	databricks workspace rm -r $(SQL_DEPLOY_PATH)
	echo "- Modules removed"
