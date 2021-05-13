# Programs
SED ?= sed
SNOWSQL ?= snowsql
GSUTIL ?= gsutil

SF_SCHEMA = $(SF_SCHEMA_PREFIX)$(MODULE)
SF_PREFIX = $(SF_DATABASE).$(SF_SCHEMA_PREFIX)
SF_SHARE_PUBLIC = $(SF_SCHEMA_PREFIX)SPATIAL_EXTENSIONS

SF_LIBRARY = ./dist/index.js

SHARE_CREATE_FILE = sql/_SHARE_CREATE.sql
SHARE_REMOVE_FILE = sql/_SHARE_REMOVE.sql

COMMON_DIR = ../../../common/snowflake/

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
	rollup --config $(COMMON_DIR)/rollup.config.js $(BUILD_PARAMS)

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
ifndef SF_DATABASE
	$(error SF_DATABASE is undefined)
endif
ifndef SF_SCHEMA
	$(error SF_SCHEMA is undefined)
endif
ifndef SF_PREFIX
	$(error SF_PREFIX is undefined)
endif
ifeq ($(SF_SHARE_ENABLED),1)
	ifndef SF_SHARE_PUBLIC
		$(error SF_SHARE_PUBLIC is undefined)
	endif
endif

##################### SNOWFLAKE SCHEMA #####################

schema_create: check_environment
	$(SNOWSQL) -q "CREATE SCHEMA IF NOT EXISTS $(SF_DATABASE).$(SF_SCHEMA)"

schema_remove: check_environment
	$(SNOWSQL) -q "DROP SCHEMA IF EXISTS $(SF_DATABASE).$(SF_SCHEMA) CASCADE"

REPLACEMENTS = 	-e 's!@@SF_PREFIX@@!$(SF_PREFIX)!g' \
		-e 's!@@SF_DATABASE@@!$(SF_DATABASE)!g' \
		-e 's!@@SF_SCHEMA@@!$(SF_SCHEMA)!g' \
		-e 's!@@SF_SHARE_PUBLIC@@!$(SF_SHARE_PUBLIC)!g' \
		-e '/@@SF_LIBRARY_CONTENT@@/ r $(SF_LIBRARY)' \
		-e 's!@@SF_LIBRARY_CONTENT@@!!g'

schema_deploy: check_environment
	for n in `node $(COMMON_DIR)/sqlsort.js`; do \
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
deploy: check_environment
	$(MAKE) schema_create
	$(MAKE) schema_deploy
	$(MAKE) share_create

##################### INTEGRATION TESTS #####################
test-integration: check_environment
	$(MAKE) deploy
	$(MAKE) test-integration-dry || ($(MAKE) integration_cleanup && exit 1)
	$(MAKE) integration_cleanup

# Note, on failure we add a explicit sleep to wait until all resources are unused before retrying
integration_cleanup: check_environment
	$(MAKE) share_remove
	$(MAKE) schema_remove || ((sleep 5 && $(MAKE) schema_remove) || exit 1)
