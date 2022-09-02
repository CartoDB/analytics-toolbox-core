# Makefile modules for Databricks

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

ENV_DIR ?= $(ROOT_DIR)/../..
CLOUD_DIR = $(ROOT_DIR)/..
COMMON_DIR = $(CLOUD_DIR)/common
SQL_PATH = $(COMMON_DIR)/dropUDF.sql

include $(COMMON_DIR)/Makefile

.SILENT:

.PHONY: help test remove

help:
	echo "Available targets: help test remove"

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
	databricks runs submit --json-file $(COMMON_DIR)/submit-run.json
	echo "- Modules removed"
