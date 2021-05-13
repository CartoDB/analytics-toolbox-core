# Programs
SED ?= sed
SNOWSQL ?= snowsql
GSUTIL ?= gsutil

SF_PREFIX = $(SF_DATABASEID).$(SF_SCHEMA_PREFIX)

SF_LIBRARY = ./dist/index.js

COMMON_DIR = ../../../common/snowflake/

SQL_DEPLOYABLE = `node ../../../common/snowflake/sqlsort.js`

NODE_MODULES = ./node_modules
NODE_MODULES_DEPS = $(COMMON_DIR)/node_modules

.PHONY: all build lint lint-fix test-unit test-integration test-integration-dry deploy clean $(NODE_MODULES) $(NODE_MODULES_DEPS) $(BQ_LIBRARY)
.SILENT: all build lint lint-fix test-unit test-integration test-integration-dry deploy $(NODE_MODULES) $(NODE_MODULES_DEPS) $(BQ_LIBRARY)

$(NODE_MODULES):
	yarn

$(NODE_MODULES_DEPS):
	yarn --cwd $(COMMON_DIR)

all build $(BQ_LIBRARY): $(NODE_MODULES) $(NODE_MODULES_DEPS)
	PATH=$(NODE_MODULES_DEPS)/.bin/:$(PATH) \
	rollup --config ../../../common/snowflake/rollup.config.js $(BUILD_PARAMS)

lint: $(NODE_MODULES_DEPS)
	PATH=$(NODE_MODULES_DEPS)/.bin/:$(PATH) \
	eslint --config ../../../.eslintrc.js .

lint-fix: $(NODE_MODULES_DEPS)
	PATH=$(NODE_MODULES_DEPS)/.bin/:$(PATH) \
	eslint --config ../../../.eslintrc.js . --fix

test-unit: $(BQ_LIBRARY)
	PATH=$(NODE_MODULES_DEPS)/.bin/:$(PATH) \
	jest test/unit --testTimeout=30000

test-integration-dry: 
	PATH=$(NODE_MODULES_DEPS)/.bin/:$(PATH) \
	jest test/integration --testTimeout=30000

clean:
	rm -rf dist $(NODE_MODULES) $(NODE_MODULES_DEPS)



check_environment:
ifndef SF_DATABASEID
	$(error SF_DATABASEID is undefined)
endif


### TODO v ###


##################### SNOWFLAKE SCHEMA #####################

schema_create: check_environment
	$(SNOWSQL) -q "CREATE SCHEMA IF NOT EXISTS $(SF_DATABASEID).$(SF_SCHEMA_PLACEKEY)"

schema_remove: check_environment
	$(SNOWSQL) -q "DROP SCHEMA IF EXISTS $(SF_DATABASEID).$(SF_SCHEMA_PLACEKEY) CASCADE"

REPLACEMENTS = 	-e 's!@@SF_DATABASEID@@!$(SF_DATABASEID)!g' \
		-e 's!@@SF_SCHEMA_PLACEKEY@@!$(SF_SCHEMA_PLACEKEY)!g' \
		-e 's!@@SF_SCHEMA_H3@@!$(SF_SCHEMA_H3)!g' \
		-e 's!@@SF_SHARE_PUBLIC@@!$(SF_SHARE_PUBLIC)!g' \
		-e '/@@LIBRARY_FILE_CONTENT@@/ r $(PLACEKEY_SF_LIBRARY)' \
		-e 's!@@LIBRARY_FILE_CONTENT@@!!g'

schema_deploy: check_environment
	for n in $(sort $(SQL_DEPLOYABLE)); do \
		$(SED) $(REPLACEMENTS) $$n | $(SNOWSQL) -q "$(xargs)" || exit; \
	done

share_create: check_environment
ifeq ($(SF_SHARE_ENABLED),1)
	$(SED) $(REPLACEMENTS) $(SHARE_CREATE_FILE) | $(SNOWSQL) -q "$(xargs)" 
endif

share_remove: check_environment
ifeq ($(SF_SHARE_ENABLED),1)
	$(SED) $(REPLACEMENTS) $(SHARE_REMOVE_FILE) | $(SNOWSQL) -q "$(xargs)" 
endif

##################### DEPLOY #####################
SF_H3_PATH = ../../h3/sf
deploy: ../placekey_library.js check_environment
	$(MAKE) -C $(SF_H3_PATH) $@
	$(MAKE) schema_create
	$(MAKE) schema_deploy
	$(MAKE) share_create

##################### INTEGRATION TESTS #####################
check-integration: check_environment
	$(MAKE) deploy
	$(MAKE) -C test/ $@ || ($(MAKE) integration_cleanup && exit 1)
	$(MAKE) integration_cleanup

# Note, on failure we add a explicit sleep to wait until all resources are unused before retrying
integration_cleanup: check_environment
ifeq ($(POST_INTEGRATION_CLEANUP),1)
	$(MAKE) share_remove
	$(MAKE) schema_remove || ((sleep 5 && $(MAKE) schema_remove) || exit 1)
	$(MAKE) -C $(SF_H3_PATH) $@
endif
