# Makefile common for Snowflake

SF_SCHEMA_DEFAULT ?= carto
SF_LIBRARY_DEFAULT ?= carto_analytics_toolbox_core
NODE_MODULES = $(ROOT_DIR)/node_modules
NODE_MODULES_DEV = $(COMMON_DIR)/node_modules

ifneq (,$(wildcard $(ENV_DIR)/.env))
    include $(ENV_DIR)/.env
	export $(shell sed 's/=.*//' $(ENV_DIR)/.env)
endif

ifeq ($(production),1)
export SF_SCHEMA = $(SF_SCHEMA_DEFAULT)
else
export SF_SCHEMA = $(SF_PREFIX)$(SF_SCHEMA_DEFAULT)
endif

.PHONY: check

check:
ifndef SF_DATABASE
	$(error SF_DATABASE is undefined)
endif
ifndef SF_ACCOUNT
	$(error SF_ACCOUNT is undefined)
endif
ifndef SF_USER
	$(error SF_USER is undefined)
endif
ifndef SF_PASSWORD
	$(error SF_PASSWORD is undefined)
endif

$(NODE_MODULES):
	yarn -s --update-checksums --cwd $(ROOT_DIR)

$(NODE_MODULES_DEV):
	yarn -s --update-checksums --cwd $(COMMON_DIR)
