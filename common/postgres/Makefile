# Makefile for Postgres modules

SED ?= sed
PSQL ?= psql
PYTHON3_VERSION ?= 3

PG_SCHEMA = $(PG_SCHEMA_PREFIX)carto
ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
PG_PREFIX = $(PG_SCHEMA_PREFIX)

CLOUD = postgres
COMMON_DIR ?= $(ROOT_DIR)/../../../common/postgres
SCRIPTS_DIR ?= $(ROOT_DIR)/../../../scripts
DIST_DIR = $(ROOT_DIR)/dist
VENV3_DIR = $(COMMON_DIR)/venv3
VENV3_ACTIVATE = $(VENV3_DIR)/bin/activate
ENV_DIR ?= $(ROOT_DIR)/../../..
PACKAGE_TYPE ?= CORE
PACKAGE_VERSION ?= dev
VERSION_FUNCTION = VERSION_$(PACKAGE_TYPE)


ifneq (,$(wildcard $(ENV_DIR)/.env))
    include $(ENV_DIR)/.env
	export $(shell sed 's/=.*//' $(ENV_DIR)/.env)
endif

REPLACEMENTS_COMMON = -e 's!@@PG_PREFIX@@!$(PG_PREFIX)!g' -e 's!@@PG_PACKAGE_VERSION@@!$(PACKAGE_VERSION)!g' \
                      -e 's!@@PG_VERSION_FUNCTION@@!$(VERSION_FUNCTION)!g' $(REPLACEMENTS_EXTRA)

REPLACEMENTS = $(REPLACEMENTS_COMMON)
REPLACEMENTS_PKG = $(REPLACEMENTS_COMMON)

PG_RUN_STATEMENT_SQL = PGPASSFILE=$(COMMON_DIR)/.pgpass ${PSQL} --no-psqlrc -h $(PG_HOST) -d $(PG_DATABASE) -U $(PG_USER)

.SILENT:

.PHONY: help lint lint-fix build test-unit test-integration test-integration-full deploy clean clean-deploy serialize-functions

help:
	echo "Please choose one of the following targets: lint, lint-fix, build, test-unit, test-integration, test-integration-full, deploy, clean, clean-deploy, serialize-functions"

lint: venv3
	. $(VENV3_ACTIVATE) && \
	flake8 lib/ test/ $(COMMON_DIR)/test_utils --enable-extensions Q0 && \
	deactivate || exit 1

lint-fix: venv3
	. $(VENV3_ACTIVATE) && \
	brunette lib/ test/ $(COMMON_DIR)/test_utils --line-length=88 --single-quotes --quiet && \
	flake8 lib/ test/ $(COMMON_DIR)/test_utils --enable-extensions Q0 && \
	deactivate || exit 1

build:
	echo "No action"

test-unit:
	echo "No action"

test-integration: check venv3
	. $(VENV3_ACTIVATE) && \
	PG_SCHEMA=$(PG_SCHEMA) pytest -rP -p no:warnings test/integration/$(TEST) && \
	deactivate || exit 1

test-integration-full:
	$(MAKE) deploy
	$(MAKE) test-integration || ($(MAKE) clean-deploy && exit 1)
	$(MAKE) clean-deploy

deploy: check install-postgis
ifdef MODULE_DEPS
	if [ "$(DEPLOY_DEPS)" = "1" ]; then \
		for module_dep in $(MODULE_DEPS); do \
			$(MAKE) -C $(MODULE_DEPS_DIR)/modules/$$module_dep/$(CLOUD) deploy || exit 1; \
		done \
	fi;
endif
	$(MAKE) schema-create
	$(MAKE) schema-deploy

clean:
	rm -rf $(DIST_DIR)
	rm -rf $(VENV3_DIR)

clean-deploy: check
ifdef MODULE_DEPS
	if [ "$(DEPLOY_DEPS)" = "1" ]; then \
		for module_dep in $(MODULE_DEPS); do \
			$(MAKE) -C $(MODULE_DEPS_DIR)/modules/$$module_dep/$(CLOUD) clean-deploy || exit 1; \
		done \
	fi;
endif
	$(MAKE) schema-remove

schema-create: pgpass
	$(PG_RUN_STATEMENT_SQL) -c "CREATE SCHEMA IF NOT EXISTS $(PG_SCHEMA)"

schema-remove: pgpass
	$(PG_RUN_STATEMENT_SQL) -c "DROP SCHEMA IF EXISTS $(PG_SCHEMA) CASCADE"

install-postgis: pgpass
	$(PG_RUN_STATEMENT_SQL) -c "CREATE EXTENSION IF NOT EXISTS postgis"

schema-deploy: pgpass
	for n in `CLOUD=$(CLOUD) node $(SCRIPTS_DIR)/sqlsort.js`; do \
		$(SED) $(REPLACEMENTS) $$n | PGOPTIONS="--search_path=$(PG_SCHEMA),public,postgres" $(PG_RUN_STATEMENT_SQL) -f -; \
	done
	$(SED) $(REPLACEMENTS) $(COMMON_DIR)/VERSION.sql | PGOPTIONS="--search_path=$(PG_SCHEMA),public,postgres" $(PG_RUN_STATEMENT_SQL) -f -;

serialize-module:
	rm -f $(DIST_DIR)/module.sql
	rm -f $(DIST_DIR)/module-header.sql
	rm -f $(DIST_DIR)/module-footer.sql
	mkdir -p $(DIST_DIR)
	touch $(DIST_DIR)/module-header.sql
	# Fixme: By now, no core module is included for postgres, so DROP_FUNCTIONS should be handled in a custom way
	# if [ "$(PACKAGE_TYPE)" = "CORE" ]; then \
	#	$(SED) $(REPLACEMENTS_PKG) $(COMMON_DIR)/DROP_FUNCTIONS.sql >> $(DIST_DIR)/module-header.sql; \
	# fi
	for n in `CLOUD=$(CLOUD) node $(SCRIPTS_DIR)/sqlsort.js`; do \
	  	$(SED) $(REPLACEMENTS_PKG) $$n >> $(DIST_DIR)/module.sql; \
		echo "" >> $(DIST_DIR)/module.sql; \
	done
	$(SED) $(REPLACEMENTS_PKG) $(COMMON_DIR)/VERSION.sql >> $(DIST_DIR)/module-footer.sql;

serialize-functions:
	mkdir -p $(DIST_DIR)
	rm -f $(DIST_DIR)/funct_names.csv
	MODULE=$(MODULE) QUALIFY=1 FILE_NAME=$${n} node $(SCRIPTS_DIR)/sqlfunctions.js >> $(DIST_DIR)/funct_names.csv

pgpass:
	echo "$(PG_HOST):5432:$(PG_DATABASE):$(PG_USER):$(PG_PASSWORD)" > $(COMMON_DIR)/.pgpass
	chmod 600 $(COMMON_DIR)/.pgpass

venv3:
	virtualenv -p python$(PYTHON3_VERSION) $(VENV3_DIR) -q
	. $(VENV3_ACTIVATE) && \
	python -m pip install -U pip -q && \
	pip install -r $(COMMON_DIR)/python3_requirements.txt -q && \
	deactivate

check:
ifndef PG_DATABASE
	$(error PG_DATABASE is undefined)
endif
ifndef PG_USER
	$(error PG_USER is undefined)
endif
ifndef PG_HOST
	$(error PG_HOST is undefined)
endif
ifndef PG_PASSWORD
	$(error PG_PASSWORD is undefined)
endif