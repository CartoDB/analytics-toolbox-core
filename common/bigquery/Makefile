# Programs
SED ?= sed
BQ ?= bq --location=$(BQ_REGION)
GSUTIL ?= gsutil

BQ_DATASET = $(BQ_DATASET_PREFIX)$(MODULE)
BQ_PREFIX = $(BQ_PROJECT).$(BQ_DATASET_PREFIX)

BQ_MODULE_CORE_LABEL = spatial_extension_module:core

BQ_PERMISSIONS_TARGET_DATASET = $(BQ_DATASET)

BQ_LIBRARY = ./dist/index.js
BQ_BUCKET = $(BQ_BUCKET_PUBLIC)$(BQ_DATASET)/
BQ_LIBRARY_BUCKET = $(BQ_BUCKET)index.js

COMMON_DIR = ../../../common/bigquery

NODE_MODULES = ./node_modules
NODE_MODULES_DEPS = $(COMMON_DIR)/node_modules

.PHONY: build lint lint-fix test-unit test-integration test-integration-dry deploy clean $(NODE_MODULES) $(NODE_MODULES_DEPS) $(BQ_LIBRARY)
.SILENT: build lint lint-fix test-unit test-integration test-integration-dry deploy $(NODE_MODULES) $(NODE_MODULES_DEPS) $(BQ_LIBRARY)

$(NODE_MODULES):
	yarn

$(NODE_MODULES_DEPS):
	yarn --cwd $(COMMON_DIR)

build $(BQ_LIBRARY): $(NODE_MODULES) $(NODE_MODULES_DEPS)
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
	jest test/integration/$(F) --testTimeout=30000 

clean:
	rm -rf dist $(NODE_MODULES) $(NODE_MODULES_DEPS)



check_environment:
ifndef BQ_REGION
	$(error BQ_REGION is undefined)
endif
ifndef BQ_PROJECT
	$(error BQ_PROJECT is undefined)
endif
ifndef BQ_PREFIX
	$(error BQ_PREFIX is undefined)
endif
ifndef BQ_BUCKET_PUBLIC
	$(error BQ_BUCKET_PUBLIC is undefined)
endif
ifndef BQ_MODULE_CORE_LABEL
	$(error BQ_MODULE_CORE_LABEL is undefined)
endif

##################### STORAGE FILES #####################

storage_upload: $(BQ_LIBRARY) check_environment
	$(GSUTIL) cp -r $(BQ_LIBRARY) $(BQ_BUCKET)

storage_remove: check_environment
	$(GSUTIL) rm -rf $(BQ_BUCKET)

##################### BIGQUERY DATASET #####################

dataset_create: check_environment
	$(BQ) --project_id $(BQ_PROJECT) show $(BQ_DATASET) 2>/dev/null 1>/dev/null || \
		$(BQ) mk -d --description "$(BQ_DATASET) module" -label $(BQ_MODULE_CORE_LABEL) $(BQ_PROJECT):$(BQ_DATASET)

dataset_remove: check_environment
	$(BQ) rm -r -f -d $(BQ_PROJECT):$(BQ_DATASET)

REPLACEMENTS = 	-e 's!@@BQ_PREFIX@@!$(BQ_PREFIX)!g' -e 's!@@BQ_LIBRARY_BUCKET@@!$(BQ_LIBRARY_BUCKET)!g'

dataset_deploy: check_environment
	for n in `node $(COMMON_DIR)/sqlsort.js`; do \
		$(SED) $(REPLACEMENTS) $$n | $(BQ) -q --project_id $(BQ_PROJECT) query --use_legacy_sql=false || exit; \
	done

##################### DEPLOY #####################

deploy: check_environment
	$(MAKE) storage_upload dataset_create
	$(MAKE) dataset_deploy
ifdef BQ_PERMISSIONS
	../../common/bigquery/set_module_permissions.sh
endif

##################### INTEGRATION TESTS #####################

test-integration: check_environment
	$(MAKE) deploy
	$(MAKE) test-integration-dry || ($(MAKE) integration_cleanup && exit 1)
	$(MAKE) integration_cleanup

# Note, on failure we add a explicit sleep to wait until all resources are unused before retrying
integration_cleanup: check_environment
	$(MAKE) storage_remove
	$(MAKE) dataset_remove || ((sleep 5 && $(MAKE) dataset_remove) || exit 1)
