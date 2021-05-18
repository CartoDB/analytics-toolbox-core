# Makefile for Snowflake modules

SED ?= sed
GSUTIL ?= gsutil
SNOWSQL ?= snowsql

SF_SCHEMA = $(SF_SCHEMA_PREFIX)$(MODULE)
SF_PREFIX = $(SF_DATABASE).$(SF_SCHEMA_PREFIX)
SF_SHARE_PUBLIC = $(SF_SCHEMA_PREFIX)SPATIAL_EXTENSIONS

SF_LIBRARY = ./dist/index.js

SHARE_CREATE_FILE = sql/_SHARE_CREATE.sql
SHARE_REMOVE_FILE = sql/_SHARE_REMOVE.sql

COMMON_DIR = ../../../common/snowflake
SCRIPTS_DIR = ../../../scripts

NODE_MODULES = ./node_modules
NODE_MODULES_DEPS = $(COMMON_DIR)/node_modules

REPLACEMENTS = 	-e 's!@@SF_PREFIX@@!$(SF_PREFIX)!g' -e 's!@@SF_DATABASE@@!$(SF_DATABASE)!g' -e 's!@@SF_SCHEMA@@!$(SF_SCHEMA)!g' -e 's!@@SF_SHARE_PUBLIC@@!$(SF_SHARE_PUBLIC)!g' -e '/@@SF_LIBRARY_CONTENT@@/ r $(SF_LIBRARY)' -e 's!@@SF_LIBRARY_CONTENT@@!!g'

.SILENT:

help:
	echo "Please choose one of the following targets: lint, lint-fix, build, test-unit, test-integration, test-integration-dry, deploy, clean, clean-deploy"

$(NODE_MODULES):
	yarn -s

$(NODE_MODULES_DEPS):
	yarn -s --cwd $(COMMON_DIR)

lint: $(NODE_MODULES_DEPS)
	PATH=$(NODE_MODULES_DEPS)/.bin/:$(PATH) \
	eslint --config ../../../.eslintrc.js .

lint-fix: $(NODE_MODULES_DEPS)
	PATH=$(NODE_MODULES_DEPS)/.bin/:$(PATH) \
	eslint --config ../../../.eslintrc.js . --fix

build: $(NODE_MODULES) $(NODE_MODULES_DEPS)
	NAME=$(MODULE)Lib \
	PATH=$(NODE_MODULES_DEPS)/.bin/:$(PATH) \
	rollup --config $(COMMON_DIR)/rollup.config.js $(BUILD_PARAMS)

test-unit:
	UNIT_TEST=1 \
	$(MAKE) build
	PATH=$(NODE_MODULES_DEPS)/.bin/:$(PATH) \
	jest test/unit --testTimeout=30000

test-integration:
	$(MAKE) deploy
	$(MAKE) test-integration-dry || ($(MAKE) clean-deploy && exit 1)
	$(MAKE) clean-deploy

test-integration-dry: check $(NODE_MODULES_DEPS)
	PATH=$(NODE_MODULES_DEPS)/.bin/:$(PATH) \
	jest test/integration/$(F) --testTimeout=30000

deploy: check
	$(MAKE) build
	$(MAKE) schema-create
	$(MAKE) schema-deploy
	$(MAKE) share-create

clean:
	rm -rf dist $(NODE_MODULES) $(NODE_MODULES_DEPS)

clean-deploy: check
	$(MAKE) share-remove
	$(MAKE) schema-remove || ((sleep 5 && $(MAKE) schema-remove) || exit 1)

schema-create:
	$(SNOWSQL) -q "CREATE SCHEMA IF NOT EXISTS $(SF_DATABASE).$(SF_SCHEMA)"

schema-remove:
	$(SNOWSQL) -q "DROP SCHEMA IF EXISTS $(SF_DATABASE).$(SF_SCHEMA) CASCADE"

schema-deploy:
	for n in `IGNORE="_SHARE_CREATE _SHARE_REMOVE" node $(SCRIPTS_DIR)/sqlsort.js`; do \
		$(SED) $(REPLACEMENTS) $$n | $(SNOWSQL) -q "$(xargs)" || exit 1; \
	done

share-create:
ifeq ($(SF_SHARE_ENABLED), 1)
	$(SED) $(REPLACEMENTS) $(SHARE_CREATE_FILE) | $(SNOWSQL) -q "$(xargs)" 
endif

share-remove:
ifeq ($(SF_SHARE_ENABLED), 1)
	$(SED) $(REPLACEMENTS) $(SHARE_REMOVE_FILE) | $(SNOWSQL) -q "$(xargs)" 
endif

check:
ifndef SF_DATABASE
	$(error SF_DATABASE is undefined)
endif
ifndef SNOWSQL_ACCOUNT
	$(error SNOWSQL_ACCOUNT is undefined)
endif
ifndef SNOWSQL_USER
	$(error SNOWSQL_USER is undefined)
endif
ifndef SNOWSQL_PWD
	$(error SNOWSQL_PWD is undefined)
endif