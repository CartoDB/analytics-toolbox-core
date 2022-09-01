# Makefile for Databricks modules

CLOUD = databricks

SQL_DEPLOY_PATH = /Shared/$(DB_DATASET_PREFIX)carto



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
