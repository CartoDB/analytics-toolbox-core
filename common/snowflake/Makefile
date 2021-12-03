# Makefile for Snowflake modules

CLOUD = snowflake

SED = sed
GSUTIL = gsutil
SNOWSQL ?= snowsql

SF_SCHEMA ?= $(SF_SCHEMA_PREFIX)carto
SF_SHARES_ROLE = ACCOUNTADMIN
SF_PREFIX = $(SF_DATABASE).$(SF_SCHEMA_PREFIX)
SF_SHARES = $(SF_SCHEMA_PREFIX)$(SF_SHARE_PREFIX)SPATIAL_EXTENSIONS

PACKAGE_VERSION ?= $(date +%Y.%m.%d)
VERSION_FUNCTION ?= VERSION_CORE

ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

LIB_DIR = $(ROOT_DIR)/lib
LIBS_DIR = $(ROOT_DIR)/libs
DIST_DIR = $(ROOT_DIR)/dist
SF_LIBRARY = $(DIST_DIR)/index.js

LINT_DIR ?= $(ROOT_DIR)/../../..
COMMON_DIR ?= $(ROOT_DIR)/../../../common/snowflake
SCRIPTS_DIR ?= $(ROOT_DIR)/../../../scripts
SHARED_DIR = $(ROOT_DIR)/../shared/javascript

SHARE_CREATE_FILE = $(COMMON_DIR)/_SHARE_CREATE.sql

NODE_MODULES = $(ROOT_DIR)/node_modules
NODE_MODULES_DEV = $(COMMON_DIR)/node_modules
NODE_MODULES_SHARED = $(SHARED_DIR)/node_modules

REPLACEMENTS_LIBS += $(foreach f,$(notdir $(basename $(wildcard ${DIST_DIR}/*.js))),-e '/@@SF_LIBRARY_$(shell echo $f | tr a-z A-Z)@@/ r ${DIST_DIR}/$f.js' -e 's!@@SF_LIBRARY_$(shell echo $f | tr a-z A-Z)@@!!g' )

REPLACEMENTS = -e 's!@@SF_PREFIX@@!$(SF_PREFIX)!g' -e 's!@@SF_DATABASE@@!$(SF_DATABASE)!g' -e 's!@@SF_SCHEMA@@!$(SF_SCHEMA)!g' \
               -e '/@@SF_LIBRARY_CONTENT@@/ r $(SF_LIBRARY)' -e 's!@@SF_LIBRARY_CONTENT@@!!g' -e 's!@@SF_PACKAGE_VERSION@@!$(PACKAGE_VERSION)!g' \
			   -e 's!@@SF_VERSION_FUNCTION@@!$(VERSION_FUNCTION)!g'
REPLACEMENTS += $(REPLACEMENTS_LIBS)

REPLACEMENTS_PKG = -e 's!@@SF_PREFIX@@!!g' -e '/@@SF_LIBRARY_CONTENT@@/ r $(SF_LIBRARY)' -e 's!@@SF_LIBRARY_CONTENT@@!!g'
REPLACEMENTS_PKG += $(REPLACEMENTS_LIBS)

.SILENT:

.PHONY: help lint lint-fix install build test-unit test-integration test-integration-full deploy clean clean-deploy serialize-module serialize-functions

help:
	echo "Please choose one of the following targets: lint, lint-fix, install, build, test-unit, test-integration, test-integration-full, deploy, clean, clean-deploy, serialize-module, serialize-functions"

$(NODE_MODULES):
	yarn -s --update-checksums

$(NODE_MODULES_DEV):
	yarn -s --update-checksums --cwd $(COMMON_DIR)

$(NODE_MODULES_SHARED):
	if [ -d ${SHARED_DIR} ]; then \
		yarn -s --update-checksums --cwd $(SHARED_DIR); \
	fi

lint: $(NODE_MODULES_DEV)
	PATH=$(NODE_MODULES_DEV)/.bin/:$(PATH) \
	eslint --config $(LINT_DIR)/.eslintrc.js .

lint-fix: $(NODE_MODULES_DEV)
	PATH=$(NODE_MODULES_DEV)/.bin/:$(PATH) \
	eslint --config $(LINT_DIR)/.eslintrc.js . --fix

install: $(NODE_MODULES) $(NODE_MODULES_SHARED) $(NODE_MODULES_DEV)

build: install
	if [ -d ${LIB_DIR} ]; then \
		NAME=$(MODULE)Lib \
		PATH=$(NODE_MODULES_DEV)/.bin/:$(PATH) \
		LIB_DIR=${LIB_DIR}/index.js \
		DIST_DIR=${DIST_DIR}/index.js \
		rollup --config $(COMMON_DIR)/rollup.config.js $(BUILD_PARAMS); \
	elif [ -d ${LIBS_DIR} ]; then \
		for f in $(notdir $(shell find ${LIBS_DIR}/* -type d 2>/dev/null)); do \
			$(PRE_BUILD) \
			NAME=$(MODULE)Lib \
			PATH=$(NODE_MODULES_DEV)/.bin/:$(PATH) \
			LIB_DIR=${LIBS_DIR}/$${f}/index.js \
			DIST_DIR=${DIST_DIR}/$${f}.js \
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
	SF_SCHEMA=$(SF_SCHEMA) \
	PATH=$(NODE_MODULES_DEV)/.bin/:$(PATH) \
	jest test/integration/$(F) --testTimeout=40000 $(TEST_INTEGRATION_EXTRA)

deploy: check
ifdef MODULE_DEPS
	for module_dep in $(MODULE_DEPS); do \
		$(MAKE) -C $(MODULE_DEPS_DIR)/modules/$$module_dep/snowflake deploy || exit 1; \
	done
endif
	$(MAKE) build
	$(MAKE) schema-create
	$(MAKE) schema-deploy
	$(MAKE) share-create

clean:
	rm -rf ${DIST_DIR} $(NODE_MODULES) $(NODE_MODULES_SHARED) $(NODE_MODULES_DEV)
	yarn -s cache clean

clean-deploy: check
ifdef MODULE_DEPS
	for module_dep in $(MODULE_DEPS); do \
		$(MAKE) -C $(MODULE_DEPS_DIR)/modules/$$module_dep/snowflake clean-deploy || exit 1; \
	done
endif
	$(MAKE) share-remove
	$(MAKE) schema-remove || ((sleep 5 && $(MAKE) schema-remove) || exit 1)

schema-create:
	$(SNOWSQL) -d $(SF_DATABASE) -q "CREATE SCHEMA IF NOT EXISTS $(SF_SCHEMA)"

schema-remove:
	$(SNOWSQL) -d $(SF_DATABASE) -q "DROP SCHEMA IF EXISTS $(SF_SCHEMA) CASCADE"

schema-deploy:
	for n in `CLOUD=$(CLOUD) node $(SCRIPTS_DIR)/sqlsort.js`; do \
		$(SED) $(REPLACEMENTS) $$n | $(SNOWSQL) -d $(SF_DATABASE) -s $(SF_SCHEMA) -q "$(xargs)" || exit 1; \
	done

share-create:
ifeq ($(SF_SHARE_ENABLED), 1)
	for share in ${SF_SHARES}; do \
		CREATE_SHARE_QUERY=$$($(SED) $(REPLACEMENTS) $(SHARE_CREATE_FILE) | $(SED) -e 's!@@SF_SHARE@@!'$$share'!g'); \
		$(SNOWSQL) -d $(SF_DATABASE) -s $(SF_SCHEMA) -r $(SF_SHARES_ROLE) -q "$$CREATE_SHARE_QUERY" || exit 1; \
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
	rm -f ${DIST_DIR}/module.sql
	echo "USE SCHEMA $(SF_DATABASE).$(SF_SCHEMA);" >> ${DIST_DIR}/module.sql
	$(SED) $(REPLACEMENTS) $(COMMON_DIR)/DROP_FUNCTIONS.sql >> ${DIST_DIR}/module.sql;
	for n in `CLOUD=$(CLOUD) node $(SCRIPTS_DIR)/sqlsort.js`; do \
	  	$(SED) $(REPLACEMENTS_PKG) $$n >> ${DIST_DIR}/module.sql; \
		echo "" >> ${DIST_DIR}/module.sql; \
	done
	$(SED) $(REPLACEMENTS) $(COMMON_DIR)/VERSION.sql >> ${DIST_DIR}/module.sql;

serialize-functions:
	mkdir -p ${DIST_DIR}
	rm -f ${DIST_DIR}/funct_names.csv
	MODULE=$(MODULE) node $(SCRIPTS_DIR)/sqlfunctions.js >> ${DIST_DIR}/funct_names.csv

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