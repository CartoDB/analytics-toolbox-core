# Makefile common for Oracle

PYTHON3_VERSION = 3
VENV3_DIR ?= $(COMMON_DIR)/../venv3
VENV3_BIN = $(VENV3_DIR)/bin
NODE_MODULES_DEV = $(COMMON_DIR)/node_modules
ORA_SCHEMA_DEFAULT ?= CARTO

ifneq (,$(wildcard $(ENV_DIR)/.env))
    include $(ENV_DIR)/.env
	export $(shell sed 's/=.*//' $(ENV_DIR)/.env)
endif

# Set ORA_SCHEMA only if not already set (allows override from outside)
ifeq ($(ORA_SCHEMA),)
  ifeq ($(production),1)
    ORA_SCHEMA = $(ORA_SCHEMA_DEFAULT)
  else
    ORA_SCHEMA = $(ORA_PREFIX)$(ORA_SCHEMA_DEFAULT)
  endif
endif

export ORA_SCHEMA

.PHONY: check venv3 $(NODE_MODULES_DEV)

check:
ifndef ORA_USER
	$(error ORA_USER is undefined. Set in .env file)
endif
ifndef ORA_PASSWORD
	$(error ORA_PASSWORD is undefined. Set in .env file)
endif
ifndef ORA_WALLET_ZIP
	$(error ORA_WALLET_ZIP is undefined. Set base64-encoded wallet ZIP in .env file)
endif
ifndef ORA_WALLET_PASSWORD
	$(error ORA_WALLET_PASSWORD is undefined. Set wallet password in .env file)
endif

venv3:
	virtualenv -p python$(PYTHON3_VERSION) $(VENV3_DIR) -q
	rm -rf $(VENV3_DIR)/lib/**/site-packages/~*
	$(VENV3_BIN)/pip install --upgrade pip -q && \
	$(VENV3_BIN)/pip install -r $(COMMON_DIR)/python3_requirements.txt -q

$(NODE_MODULES_DEV):
	yarn -s --update-checksums --cwd $(COMMON_DIR)
