# Programs
SED ?= sed
SNOWSQL ?= snowsql
GSUTIL ?= gsutil

ENABLE_SHARE ?= 1
POST_INTEGRATION_CLEANUP ?= 1

# Deployment variables
QUADKEY_SF_LIBRARY ?= ../quadkey_library.js

.PHONY: ../quadkey_library.js
../quadkey_library.js:
	$(MAKE) -C .. all

SQL_FILES =  $(wildcard sql/*.sql)
SHARE_FILE = sql/_SETUP_SHARE.sql
SQL_DEPLOYABLE = $(filter-out ${SHARE_FILE},${SQL_FILES})

.PHONY: check_environment all check clean database_create schema_create schema_remove schema_deploy setup-share deploy check-integration integration_cleanup
check_environment:
ifndef SF_DATABASEID
	$(error SF_DATABASEID is undefined)
endif
ifndef SF_SCHEMA_QUADKEY
	$(error SF_SCHEMA_QUADKEY is undefined)
endif

all check:

clean:
	$(MAKE) -C test/ $@

##################### SFOWFLAKE SCHEMA #####################

database_create: check_environment
	$(SNOWSQL) -q "CREATE DATABASE IF NOT EXISTS $(SF_DATABASEID)"

schema_create: check_environment
	$(SNOWSQL) -q "CREATE SCHEMA IF NOT EXISTS $(SF_DATABASEID).$(SF_SCHEMA_QUADKEY)"

schema_remove: check_environment
	$(SNOWSQL) -q "DROP SCHEMA IF EXISTS $(SF_DATABASEID).$(SF_SCHEMA_QUADKEY) CASCADE"

REPLACEMENTS = 	-e 's!@@SF_DATABASEID@@!$(SF_DATABASEID)!g' \
		-e 's!@@SF_SCHEMA_QUADKEY@@!$(SF_SCHEMA_QUADKEY)!g' \
		-e 's!@@SF_SHARE_QUADKEY@@!$(SF_SHARE_QUADKEY)!g' \
		-e '/@@WASM_FILE_CONTENTS@@/ r $(QUADKEY_SF_LIBRARY)' \
		-e 's!@@WASM_FILE_CONTENTS@@!!g'

schema_deploy: check_environment
	for n in $(SQL_DEPLOYABLE); do \
		$(SED) $(REPLACEMENTS) $$n | $(SNOWSQL) -q "$(cat /dev/stdin)" || exit; \
	done
	$(MAKE) setup-share

setup-share: check_environment
ifeq ($(ENABLE_SHARE),1)
	$(SED) $(REPLACEMENTS) $(SHARE_FILE) | $(SNOWSQL) -q "$(cat /dev/stdin)" 
endif

##################### DEPLOY #####################
deploy: check_environment
	$(MAKE) database_create schema_create
	$(MAKE) schema_deploy

##################### INTEGRATION TESTS #####################
check-integration: check_environment
	$(MAKE) deploy
	$(MAKE) -C test/ $@ || ($(MAKE) integration_cleanup && exit 1)
	$(MAKE) integration_cleanup

# Note, on failure we add a explicit sleep to wait until all resources are unused before retrying
integration_cleanup: check_environment
ifeq ($(POST_INTEGRATION_CLEANUP),1)
	$(MAKE) schema_remove || ((sleep 5 && $(MAKE) schema_remove) || exit 1)
endif
