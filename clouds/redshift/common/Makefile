# Makefile common for Redshift

PYTHON3_VERSION = 3
VENV3_DIR ?= $(COMMON_DIR)/../venv3
VENV3_BIN = $(VENV3_DIR)/bin
RS_SCHEMA_DEFAULT ?= carto
NODE_MODULES_DEV = $(COMMON_DIR)/node_modules

ifneq (,$(wildcard $(ENV_DIR)/.env))
    include $(ENV_DIR)/.env
	export $(shell sed 's/=.*//' $(ENV_DIR)/.env)
endif

# Set RS_SCHEMA only if not already set (allows override from outside)
ifeq ($(RS_SCHEMA),)
  ifeq ($(production),1)
    RS_SCHEMA = $(RS_SCHEMA_DEFAULT)
  else
    RS_SCHEMA = $(RS_PREFIX)$(RS_SCHEMA_DEFAULT)
  endif
endif

export RS_SCHEMA

.PHONY: check venv3 $(NODE_MODULES_DEV)

check:
ifndef RS_HOST
	$(error RS_HOST is undefined)
endif
ifndef RS_DATABASE
	$(error RS_DATABASE is undefined)
endif
ifndef RS_USER
	$(error RS_USER is undefined)
endif
ifndef RS_PASSWORD
	$(error RS_PASSWORD is undefined)
endif
ifndef AWS_ACCESS_KEY_ID
	$(error AWS_ACCESS_KEY_ID is undefined)
endif
ifndef AWS_SECRET_ACCESS_KEY
	$(error AWS_SECRET_ACCESS_KEY is undefined)
endif
ifeq ($(shell echo "$(RS_HOST)" | grep -E "^([^.]+)\.([^.]+)\.([^.]+)\.redshift(-serverless)?\.amazonaws\.com$$"),)
	$(error RS_HOST is not valid. Must be: <cluster>.<account>.<region>.redshift(-serverless).amazonaws.com)
endif

venv3:
	virtualenv -p python$(PYTHON3_VERSION) $(VENV3_DIR) -q
	rm -rf $(VENV3_DIR)/lib/**/site-packages/~*
	$(VENV3_BIN)/pip install --upgrade pip -q && \
	$(VENV3_BIN)/pip install -r $(COMMON_DIR)/python3_requirements.txt -q

$(NODE_MODULES_DEV):
	yarn -s --update-checksums --cwd $(COMMON_DIR)
