# Makefile for Databricks modules

PYTHON3_VERSION = 3
VENV3_DIR ?= $(COMMON_DIR)/../venv3
VENV3_BIN = $(VENV3_DIR)/bin
DB_SCHEMA_DEFAULT = carto
NODE_MODULES_DEV = $(COMMON_DIR)/node_modules

ifneq (,$(wildcard $(ENV_DIR)/.env))
    include $(ENV_DIR)/.env
	export $(shell sed 's/=.*//' $(ENV_DIR)/.env)
endif

ifdef catalog
export DB_CATALOG = $(catalog)
endif

ifeq ($(production),1)
export DB_SCHEMA = \`$(DB_CATALOG)\`.\`$(DB_SCHEMA_DEFAULT)\`
export DB_UNQUALIFIED_SCHEMA = $(DB_SCHEMA_DEFAULT)
else
export DB_SCHEMA = \`$(DB_CATALOG)\`.\`$(DB_PREFIX)$(DB_SCHEMA_DEFAULT)\`
export DB_UNQUALIFIED_SCHEMA = $(DB_PREFIX)$(DB_SCHEMA_DEFAULT)
endif

.SILENT:

.PHONY: check venv3 $(NODE_MODULES_DEV)

check:
ifndef DB_HOST_NAME
	$(error DB_HOST_NAME is undefined)
endif
ifndef DB_HTTP_PATH
	$(error DB_HTTP_PATH is undefined)
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
