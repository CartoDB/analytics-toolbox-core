# Makefile common for Postgres

PYTHON3_VERSION = 3
VENV3_DIR ?= $(COMMON_DIR)/../venv3
VENV3_BIN = $(VENV3_DIR)/bin
PG_SCHEMA_DEFAULT ?= carto
PG_LIBRARY_DEFAULT ?= carto_analytics_toolbox_core
NODE_MODULES_DEV = $(COMMON_DIR)/node_modules

ifneq (,$(wildcard $(ENV_DIR)/.env))
    include $(ENV_DIR)/.env
	export $(shell sed 's/=.*//' $(ENV_DIR)/.env)
endif

ifeq ($(production),1)
export PG_SCHEMA = $(PG_SCHEMA_DEFAULT)
export PG_LIBRARY = $(PG_LIBRARY_DEFAULT)
else
export PG_SCHEMA = $(PG_PREFIX)$(PG_SCHEMA_DEFAULT)
export PG_LIBRARY = $(PG_PREFIX)$(PG_LIBRARY_DEFAULT)
endif

.PHONY: check venv3

check:
ifndef PG_PREFIX
	$(error PG_PREFIX is undefined)
endif
ifndef PG_HOST
	$(error PG_HOST is undefined)
endif
ifndef PG_DATABASE
	$(error PG_DATABASE is undefined)
endif
ifndef PG_USER
	$(error PG_USER is undefined)
endif
ifndef PG_PASSWORD
	$(error PG_PASSWORD is undefined)
endif

venv3:
	virtualenv -p python$(PYTHON3_VERSION) $(VENV3_DIR) -q
	$(VENV3_BIN)/pip install --upgrade pip -q && \
	$(VENV3_BIN)/pip install -r $(COMMON_DIR)/python3_requirements.txt -q

$(NODE_MODULES_DEV):
	yarn -s --update-checksums --cwd $(COMMON_DIR)
