# Makefile for Databricks modules

PYTHON3_VERSION = 3
VENV3_DIR ?= $(COMMON_DIR)/../venv3
VENV3_BIN = $(VENV3_DIR)/bin
SQL_DEPLOY_PATH = /Shared/$(DB_PREFIX)carto
NODE_MODULES_DEV = $(COMMON_DIR)/node_modules

ifneq (,$(wildcard $(ENV_DIR)/.env))
    include $(ENV_DIR)/.env
	export $(shell sed 's/=.*//' $(ENV_DIR)/.env)
endif

.SILENT:

.PHONY: check venv

venv:
	virtualenv -p python3 $(COMMON_DIR)/venv -q
	. $(COMMON_DIR)/venv/bin/activate && \
	python -m pip install -U pip -q && \
	pip install -r $(COMMON_DIR)/requirements.txt -q && \
	deactivate

check:
ifndef DB_CLUSTER_ID
	$(error DB_CLUSTER_ID env variable is mandatory)
endif

check-extra:
ifndef DATABRICKS_SERVER_HOSTNAME
	$(error DATABRICKS_SERVER_HOSTNAME is undefined)
endif
ifndef DATABRICKS_HTTP_PATH
	$(error DATABRICKS_HTTP_PATH is undefined)
endif
ifndef DATABRICKS_TOKEN
	$(error DATABRICKS_TOKEN is undefined)
endif

venv3:
	virtualenv -p python$(PYTHON3_VERSION) $(VENV3_DIR) -q
	$(VENV3_BIN)/pip install --upgrade pip -q && \
	$(VENV3_BIN)/pip install -r $(COMMON_DIR)/python3_requirements.txt -q

$(NODE_MODULES_DEV):
	yarn -s --update-checksums --cwd $(COMMON_DIR)