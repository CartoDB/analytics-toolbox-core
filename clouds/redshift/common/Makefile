# Makefile common for Redshift

PYTHON2_VERSION = 2.7
PYTHON3_VERSION = 3

VENV2_DIR = $(COMMON_DIR)/../venv2
VENV3_DIR = $(COMMON_DIR)/../venv3
VENV2_BIN = $(VENV2_DIR)/bin
VENV3_BIN = $(VENV3_DIR)/bin

NODE_MODULES_DEV = $(COMMON_DIR)/node_modules

ifneq (,$(wildcard $(ENV_DIR)/.env))
    include $(ENV_DIR)/.env
	export $(shell sed 's/=.*//' $(ENV_DIR)/.env)
endif

ifeq ($(production),1)
export RS_SCHEMA = carto
export RS_LIBRARY = carto_analytics_toolbox_core
else
export RS_SCHEMA = $(RS_PREFIX)carto
export RS_LIBRARY = $(RS_PREFIX)carto_analytics_toolbox_core
endif

.PHONY: check venv2 venv3

check:
ifndef RS_PREFIX
	$(error RS_PREFIX is undefined)
endif
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

venv2:
	virtualenv -p python$(PYTHON2_VERSION) $(VENV2_DIR) -q
	$(VENV2_BIN)/pip install --upgrade pip -q 2>/dev/null && \
	$(VENV2_BIN)/pip install -r $(COMMON_DIR)/python2_requirements.txt -q 2>/dev/null
	([ ! -f requirements.txt ] || $(VENV2_BIN)/pip install -r requirements.txt -q 2>/dev/null)

venv3:
	virtualenv -p python$(PYTHON3_VERSION) $(VENV3_DIR) -q
	$(VENV3_BIN)/pip install --upgrade pip -q && \
	$(VENV3_BIN)/pip install -r $(COMMON_DIR)/python3_requirements.txt -q

$(NODE_MODULES_DEV):
	yarn -s --update-checksums --cwd $(COMMON_DIR)
