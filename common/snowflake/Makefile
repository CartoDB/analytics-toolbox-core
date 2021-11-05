# Makefile for Snowflake modules

SED ?= sed
GSUTIL ?= gsutil
SNOWSQL ?= snowsql

SF_SCHEMA = $(SF_SCHEMA_PREFIX)carto
SF_SHARES_ROLE = ACCOUNTADMIN
SF_PREFIX = $(SF_DATABASE).$(SF_SCHEMA_PREFIX)
SF_SHARES = \
	$(SF_SCHEMA_PREFIX)$(SF_SHARE_PREFIX)SPATIAL_EXTENSIONS \
	$(SF_SCHEMA_PREFIX)$(SF_SHARE_PREFIX)ADVANCED_SPATIAL_EXTENSIONS 

ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

SF_LIBRARY = $(ROOT_DIR)/dist/index.js

COMMON_DIR = $(ROOT_DIR)/../../../common/snowflake
SCRIPTS_DIR = $(ROOT_DIR)/../../../scripts
SHARED_DIR = $(ROOT_DIR)/../shared/javascript

SHARE_CREATE_FILE = $(COMMON_DIR)/_SHARE_CREATE.sql

NODE_MODULES = $(ROOT_DIR)/node_modules
NODE_MODULES_DEV = $(COMMON_DIR)/node_modules
NODE_MODULES_SHARED = $(SHARED_DIR)/node_modules

UPDATE_CHECKSUMS = #--update-checksums

REPLACEMENTS_LIBS += $(foreach f,$(notdir $(basename $(wildcard dist/*.js))),-e '/@@SF_LIBRARY_$(shell echo $f | tr a-z A-Z)@@/ r ./dist/$f.js' -e 's!@@SF_LIBRARY_$(shell echo $f | tr a-z A-Z)@@!!g' )

REPLACEMENTS = 	-e 's!@@SF_PREFIX@@!$(SF_PREFIX)!g' -e 's!@@SF_DATABASE@@!$(SF_DATABASE)!g' -e 's!@@SF_SCHEMA@@!$(SF_SCHEMA)!g' -e '/@@SF_LIBRARY_CONTENT@@/ r $(SF_LIBRARY)' -e 's!@@SF_LIBRARY_CONTENT@@!!g'
REPLACEMENTS += $(REPLACEMENTS_LIBS)

REPLACEMENTS_PKG = -e 's!@@SF_PREFIX@@!!g' -e '/@@SF_LIBRARY_CONTENT@@/ r $(SF_LIBRARY)' -e 's!@@SF_LIBRARY_CONTENT@@!!g'
REPLACEMENTS_PKG += $(REPLACEMENTS_LIBS)

.SILENT:

.PHONY: help lint lint-fix build test-unit test-integration test-integration-full deploy clean clean-deploy serialize-module serialize-functions

help:
	echo "Please choose one of the following targets: lint, lint-fix, build, test-unit, test-integration, test-integration-full, deploy, clean, clean-deploy, serialize-functions"

$(NODE_MODULES):
	yarn -s $(UPDATE_CHECKSUMS)

$(NODE_MODULES_DEV):
	yarn -s $(UPDATE_CHECKSUMS) --cwd $(COMMON_DIR)

$(NODE_MODULES_SHARED):
	yarn -s $(UPDATE_CHECKSUMS) --cwd $(SHARED_DIR)

lint: $(NODE_MODULES_DEV)
	PATH=$(NODE_MODULES_DEV)/.bin/:$(PATH) \
	eslint --config ../../../.eslintrc.js .

lint-fix: $(NODE_MODULES_DEV)
	PATH=$(NODE_MODULES_DEV)/.bin/:$(PATH) \
	eslint --config ../../../.eslintrc.js . --fix

build: $(NODE_MODULES) $(NODE_MODULES_SHARED) $(NODE_MODULES_DEV)
	if [ -d ./lib ]; then \
		NAME=$(MODULE)Lib \
		PATH=$(NODE_MODULES_DEV)/.bin/:$(PATH) \
		LIB_DIR=./lib/index.js \
		DIST_DIR=./dist/index.js \
		rollup --config $(COMMON_DIR)/rollup.config.js $(BUILD_PARAMS); \
	elif [ -d ./libs ]; then \
		for f in $(notdir $(shell find ./libs/* -type d 2>/dev/null)); do \
			$(PRE_BUILD) \
			NAME=$(MODULE)Lib \
			PATH=$(NODE_MODULES_DEV)/.bin/:$(PATH) \
			LIB_DIR=./libs/$${f}/index.js \
			DIST_DIR=./dist/$${f}.js \
			rollup --config $(COMMON_DIR)/rollup.config.js $(BUILD_PARAMS); \
			$(POST_BUILD) \
		done \
    fi

test-unit:
	UNIT_TEST=1 \
	$(MAKE) build
	PATH=$(NODE_MODULES_DEV)/.bin/:$(PATH) \
	jest test/unit --testTimeout=30000

test-integration-full:
	$(MAKE) deploy
	$(MAKE) test-integration || ($(MAKE) clean-deploy && exit 1)
	$(MAKE) clean-deploy

test-integration: check $(NODE_MODULES_DEV)
	SF_SCHEMA=$(SF_SCHEMA) PATH=$(NODE_MODULES_DEV)/.bin/:$(PATH) \
	jest test/integration/$(TEST) --testTimeout=30000

deploy: check
	$(MAKE) build
	$(MAKE) schema-create
	$(MAKE) schema-deploy
	$(MAKE) share-create

clean:
	rm -rf dist $(NODE_MODULES) $(NODE_MODULES_DEV)

clean-deploy: check
	$(MAKE) share-remove
	$(MAKE) schema-remove || ((sleep 5 && $(MAKE) schema-remove) || exit 1)

schema-create:
	$(SNOWSQL) -d $(SF_DATABASE) -q "CREATE SCHEMA IF NOT EXISTS $(SF_SCHEMA)"

schema-remove:
	$(SNOWSQL) -d $(SF_DATABASE) -q "DROP SCHEMA IF EXISTS $(SF_SCHEMA) CASCADE"

schema-deploy:
	for n in `node $(SCRIPTS_DIR)/sqlsort.js`; do \
		$(SED) $(REPLACEMENTS) $$n | $(SNOWSQL) -d $(SF_DATABASE) -s $(SF_SCHEMA) -q "$(xargs)" || exit 1; \
	done
	$(SED) $(REPLACEMENTS) $(COMMON_DIR)/VERSION/sql/VERSION.sql | $(SNOWSQL) -d $(SF_DATABASE) -s $(SF_SCHEMA) -q "$(xargs)" || exit 1

share-create:
ifeq ($(SF_SHARE_ENABLED), 1)
	for share in ${SF_SHARES}; do \
		CREATE_SHARE_QUERY=$$($(SED) $(REPLACEMENTS) $(SHARE_CREATE_FILE) | $(SED) -e 's!@@SF_SHARE@@!'$$share'!g'); \
		$(SNOWSQL) -d $(SF_DATABASE) -s $(SF_SCHEMA) -r $(SF_SHARES_ROLE) -q "$$CREATE_SHARE_QUERY" || exit 1; \
		SHARE_VERSION_QUERY="GRANT USAGE ON FUNCTION VERSION() TO SHARE $$share;"; \
		$(SNOWSQL) -d $(SF_DATABASE) -s $(SF_SCHEMA) -r $(SF_SHARES_ROLE) -q "$$SHARE_VERSION_QUERY" || exit 1; \
		for f in `OUTPUT_FORMAT='argTypes' DELIMITER=' ' MODULE=$(MODULE) FILE_NAME=$${n} node $(SCRIPTS_DIR)/sqlfunctions.js`; do \
			SHARE_FUNCTION_QUERY="GRANT USAGE ON FUNCTION $$f TO SHARE $$share;"; \
			$(SNOWSQL) -d $(SF_DATABASE) -s $(SF_SCHEMA) -r $(SF_SHARES_ROLE) -q "$$SHARE_FUNCTION_QUERY" || exit 1; \
		done \
	done
endif

share-remove:
ifeq ($(SF_SHARE_ENABLED), 1)
	for share in ${SF_SHARES}; do \
		SHARE_QUERY="DROP SHARE $$share;"; \
		$(SNOWSQL) -d $(SF_DATABASE) -s $(SF_SCHEMA) -r $(SF_SHARES_ROLE) -q "$$SHARE_QUERY" || exit 1; \
	done
endif

serialize-module:
	$(MAKE) build
	rm -f dist/module.sql
	echo "CREATE SCHEMA IF NOT EXISTS $(SF_SCHEMA);" >> dist/module.sql
	for n in `node $(SCRIPTS_DIR)/sqlsort.js`; do \
	  	$(SED) $(REPLACEMENTS_PKG) $$n >> dist/module.sql; \
		echo "" >> dist/module.sql; \
	done

serialize-functions:
	mkdir -p dist
	rm -f dist/funct_names.csv
	MODULE=$(MODULE) QUALIFY=1 FILE_NAME=$${n} node $(SCRIPTS_DIR)/sqlfunctions.js >> dist/funct_names.csv

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