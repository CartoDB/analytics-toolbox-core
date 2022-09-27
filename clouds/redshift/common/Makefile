# Makefile common for Redshift

PYTHON2_VERSION = 2.7
PYTHON3_VERSION = 3
VENV2_DIR ?= $(COMMON_DIR)/../venv2
VENV3_DIR ?= $(COMMON_DIR)/../venv3
VENV2_BIN = $(VENV2_DIR)/bin
VENV3_BIN = $(VENV3_DIR)/bin
RS_SCHEMA_DEFAULT ?= carto
RS_LIBRARY_DEFAULT ?= carto_analytics_toolbox_core
NODE_MODULES_DEV = $(COMMON_DIR)/node_modules

ifneq (,$(wildcard $(ENV_DIR)/.env))
    include $(ENV_DIR)/.env
	export $(shell sed 's/=.*//' $(ENV_DIR)/.env)
endif

ifeq ($(production),1)
export RS_SCHEMA = $(RS_SCHEMA_DEFAULT)
export RS_LIBRARY = $(RS_LIBRARY_DEFAULT)
else
export RS_SCHEMA = $(RS_PREFIX)$(RS_SCHEMA_DEFAULT)
export RS_LIBRARY = $(RS_PREFIX)$(RS_LIBRARY_DEFAULT)
endif

.PHONY: check venv2 venv3 $(NODE_MODULES_DEV)

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
ifndef RS_BUCKET
	$(error RS_BUCKET is undefined)
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
ifeq ($(shell echo "$(RS_BUCKET)" | grep -E "^s3://(.+)[^/]$$"),)
	$(error RS_BUCKET is not valid. Must be: s3://<bucket> or s3://<bucket>/<folder>)
endif

venv2:
	virtualenv -p python$(PYTHON2_VERSION) $(VENV2_DIR) -q
	rm -rf $(VENV2_DIR)/lib/**/site-packages/~*
	$(VENV2_BIN)/pip install --upgrade pip -q 2>/dev/null && \
	$(VENV2_BIN)/pip install -r $(COMMON_DIR)/python2_requirements.txt -q 2>/dev/null
	([ ! -f $(ROOT_DIR)/requirements.txt ] || $(VENV2_BIN)/pip install -r $(ROOT_DIR)/requirements.txt -q 2>/dev/null)

venv3:
	virtualenv -p python$(PYTHON3_VERSION) $(VENV3_DIR) -q
	rm -rf $(VENV3_DIR)/lib/**/site-packages/~*
	$(VENV3_BIN)/pip install --upgrade pip -q && \
	$(VENV3_BIN)/pip install -r $(COMMON_DIR)/python3_requirements.txt -q

$(NODE_MODULES_DEV):
	yarn -s --update-checksums --cwd $(COMMON_DIR)
