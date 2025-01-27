# Makefile common for Snowflake

PYTHON3_VERSION = 3
VENV3_DIR ?= $(COMMON_DIR)/../venv3
VENV3_BIN = $(VENV3_DIR)/bin
NODE_MODULES_DEV = $(COMMON_DIR)/node_modules
export SF_SCHEMA_DEFAULT = CARTO

ifneq (,$(wildcard $(ENV_DIR)/.env))
    include $(ENV_DIR)/.env
	export $(shell sed 's/=.*//' $(ENV_DIR)/.env)
endif

ifdef database
export SF_DATABASE = $(database)
endif

ifeq ($(production),1)
export SF_SCHEMA = $(SF_DATABASE).$(SF_SCHEMA_DEFAULT)
export SF_UNQUALIFIED_SCHEMA = $(SF_SCHEMA_DEFAULT)
else
export SF_SCHEMA = $(SF_DATABASE).$(SF_PREFIX)$(SF_SCHEMA_DEFAULT)
export SF_UNQUALIFIED_SCHEMA = $(SF_PREFIX)$(SF_SCHEMA_DEFAULT)
endif

.PHONY: check venv3 $(NODE_MODULES_DEV)

check:
ifndef SF_ACCOUNT
	$(error SF_ACCOUNT is undefined)
endif
ifndef SF_DATABASE
	$(error SF_DATABASE is undefined)
endif
ifndef SF_USER
	$(error SF_USER is undefined)
endif
ifndef SF_PASSWORD
	$(error SF_PASSWORD is undefined)
endif
ifndef SF_ACCOUNT
	$(error SF_ACCOUNT is undefined)
endif

venv3:
	virtualenv -p python$(PYTHON3_VERSION) $(VENV3_DIR) -q
	rm -rf $(VENV3_DIR)/lib/**/site-packages/~*
	$(VENV3_BIN)/pip install --upgrade pip -q && \
	$(VENV3_BIN)/pip install -r $(COMMON_DIR)/python3_requirements.txt -q

$(NODE_MODULES_DEV):
	yarn -s --update-checksums --cwd $(COMMON_DIR)
