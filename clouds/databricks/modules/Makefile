# Makefile modules for Databricks

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

ENV_DIR ?= $(ROOT_DIR)/..
TEST_DIR ?= $(ROOT_DIR)/test
SQL_DIR ?= $(ROOT_DIR)/sql
COMMON_DIR = $(ROOT_DIR)/../common
BUILD_DIR = $(ROOT_DIR)/build

include $(COMMON_DIR)/Makefile

.SILENT:

.PHONY: help lint test remove

help:
	echo "Available targets: help test remove"

lint: venv3 $(NODE_MODULES_DEV)
	echo "Linting modules..."
	echo "- Lint Markdown files"
	PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
	markdownlint -f '**/*.md' --ignore **/node_modules/** --disable MD013 MD024 MD033 MD036 MD040 MD041 MD051 --
	echo "- Lint SQL files"
	$(VENV3_BIN)/python $(COMMON_DIR)/sql_lint.py "$(wildcard $(SQL_DIR)/**/*.sql)" $(COMMON_DIR)/.sqlfluff "$(wildcard $(SQL_DIR)/.sqlfluffignore)" || exit 1

test: check check-extra venv
	echo "Testing modules..."
	. $(COMMON_DIR)/venv/bin/activate && \
	for module in `ls $(TEST_DIR)`; do \
		echo "> Module $${module}"; \
		pytest -rP -p no:warnings -vv $(TEST_DIR)/$${module} || exit 1; \
	done; \
	deactivate

remove: check
	echo "Removing modules..."
	python3 $(COMMON_DIR)/python_utils/create_drop_functions.py $(BUILD_DIR)/drop.sql
	databricks workspace mkdirs $(SQL_DEPLOY_PATH)
	databricks workspace import --overwrite --language SQL $(BUILD_DIR)/drop.sql $(SQL_DEPLOY_PATH)/drop.sql
	$(MAKE) drop-udfs

drop-udfs:
	sed -e 's/@@DB_CLUSTER_ID@@/${DB_CLUSTER_ID}/g' -e 's!@@SQLPath@@!$(SQL_DEPLOY_PATH)/drop.sql!g' $(COMMON_DIR)/submit-run-template.json > $(COMMON_DIR)/submit-run.json
	databricks runs submit --json-file $(COMMON_DIR)/submit-run.json --wait
	echo "- Removing drop script from the workspace"
	databricks workspace rm -r $(SQL_DEPLOY_PATH)
	echo "- Modules removed"

build: # modules/sql/*.sql -> modules/build/modules.sql
	echo "Building modules..."
ifndef DB_SCHEMA
	echo "- Databricks schema not defined, using default"
	$(eval DB_SCHEMA := default)
endif
	python3 $(COMMON_DIR)/python_utils/create_modules_sql.py $(BUILD_DIR)/modules.sql $(DB_SCHEMA)

upload-sql:
	echo "- Installing create functions"
	databricks workspace mkdirs $(SQL_DEPLOY_PATH)
	databricks workspace import --overwrite --language SQL $(BUILD_DIR)/modules.sql $(SQL_DEPLOY_PATH)/modules.sql
	echo "- Create functions installed"

create-udfs:
	echo "- Running create functions"
	sed -e 's/@@DB_CLUSTER_ID@@/${DB_CLUSTER_ID}/g' -e 's!@@SQLPath@@!$(SQL_DEPLOY_PATH)/modules.sql!g' $(COMMON_DIR)/submit-run-template.json > $(COMMON_DIR)/submit-run.json
	databricks runs submit --json-file $(COMMON_DIR)/submit-run.json --wait
	echo "- Removing install script from the workspace"
	databricks workspace rm -r $(SQL_DEPLOY_PATH)
	echo "- Create functions ran"

deploy: check build
	echo "Deploying modules..."
	$(MAKE) upload-sql
	$(MAKE) create-udfs

clean:
	echo "Cleaning modules..."
	rm -rf $(BUILD_DIR)
