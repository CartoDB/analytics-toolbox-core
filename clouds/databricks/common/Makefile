# Makefile for Databricks modules

PYTHON3_VERSION = 3
VENV3_DIR ?= $(COMMON_DIR)/../venv3
VENV3_BIN = $(VENV3_DIR)/bin
NODE_MODULES_DEV = $(COMMON_DIR)/node_modules
DB_SCHEMA_DEFAULT = carto
COMMON_ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
VERSION_FILE ?= $(COMMON_ROOT_DIR)/../version

ifeq ($(production),1)
export DB_PACKAGE_VERSION = $(shell cat $(VERSION_FILE))
else
export DB_PACKAGE_VERSION = $(shell cat $(VERSION_FILE))-dev-SNAPSHOT
endif

ifneq (,$(wildcard $(ENV_DIR)/.env))
    include $(ENV_DIR)/.env
	export $(shell sed 's/=.*//' $(ENV_DIR)/.env)
endif

ifeq ($(production),1)
export DB_SCHEMA = $(DB_SCHEMA_DEFAULT)
else
export DB_SCHEMA = $(DB_PREFIX)$(DB_SCHEMA_DEFAULT)
endif

ifdef DB_HOST
export DATABRICKS_HOST = https://$(DB_HOST)
endif
ifdef DB_TOKEN
export DATABRICKS_TOKEN = $(DB_TOKEN)
endif

SQL_DEPLOY_PATH = /Shared/$(DB_SCHEMA)


.SILENT:

.PHONY: check venv3 $(NODE_MODULES_DEV)

check:
ifndef DB_CLUSTER_ID
	$(error DB_CLUSTER_ID env variable is mandatory)
endif

check-extra:
ifndef DB_HTTP_PATH
	$(error DB_HTTP_PATH is undefined)
endif
ifndef DB_HOST
	$(error DB_HOST is undefined)
endif
ifndef DB_TOKEN
	$(error DB_TOKEN is undefined)
endif

venv3:
	virtualenv -p python$(PYTHON3_VERSION) $(VENV3_DIR) -q
	$(VENV3_BIN)/pip install --upgrade pip -q && \
	$(VENV3_BIN)/pip install -r $(COMMON_DIR)/python3_requirements.txt -q

$(NODE_MODULES_DEV):
	yarn -s --update-checksums --cwd $(COMMON_DIR)