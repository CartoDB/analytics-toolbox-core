# Makefile common for Oracle

PYTHON3_VERSION = 3
VENV3_DIR ?= $(COMMON_DIR)/../venv3
VENV3_BIN = $(VENV3_DIR)/bin
NODE_MODULES_DEV = $(COMMON_DIR)/node_modules

ifneq (,$(wildcard $(ENV_DIR)/.env))
    include $(ENV_DIR)/.env
	export $(shell sed 's/=.*//' $(ENV_DIR)/.env)
endif

# ORA_SCHEMA is required - no default value
# Oracle schemas are tied to users (pre-created), so explicit naming is required
export ORA_SCHEMA

.PHONY: check venv3 $(NODE_MODULES_DEV)

check:
ifndef ORA_SCHEMA
	$(error ORA_SCHEMA is undefined. Set in .env file (e.g., ORA_SCHEMA=DEV_CARTO or ORA_SCHEMA=CARTO))
endif
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
