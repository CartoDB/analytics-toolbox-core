# Makefile common for Snowflake

SF_DATABASE_TEMPLATE = @@DATABASE@@
NODE_MODULES_DEV = $(COMMON_DIR)/node_modules
export SF_SCHEMA_DEFAULT = carto

ifneq (,$(wildcard $(ENV_DIR)/.env))
    include $(ENV_DIR)/.env
	export $(shell sed 's/=.*//' $(ENV_DIR)/.env)
endif

ifeq ($(production),1)
export SF_SCHEMA = $(SF_DATABASE_TEMPLATE).$(SF_SCHEMA_DEFAULT)
else
export SF_SCHEMA = $(SF_DATABASE).$(SF_PREFIX)$(SF_SCHEMA_DEFAULT)
endif

.PHONY: check

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
ifeq ($(shell echo "$(SF_ACCOUNT)" | grep -E "^([^.]+)\.([^.]+)$$"),)
	$(error SF_ACCOUNT is not valid. Must be: <account>.<region>)
endif

$(NODE_MODULES_DEV):
	yarn -s --update-checksums --cwd $(COMMON_DIR)
