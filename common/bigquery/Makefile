# Programs
SED ?= sed
BQ ?= bq --location=$(BQ_REGION)
GSUTIL ?= gsutil
SHELL := bash

export BQ_DATASET = $(BQ_DATASET_PREFIX)$(MODULE)
BQ_MODULE_CORE_LABEL = spatial_extension_module:core

POST_INTEGRATION_CLEANUP ?= 1

BQ_PERMISSIONS_TARGET_DATASET = $(BQ_DATASET)

BQ_LIBRARY = ./dist/main.js
BQ_LIBRARY_BUCKET ?= $(BQ_BUCKET_PUBLIC)$(BQ_DATASET)/main.js

.PHONY: $(BQ_LIBRARY)
$(BQ_LIBRARY):
	yarn build

.PHONY: check_environment all check clean storage_upload storage_remove dataset_create dataset_remove dataset_deploy deploy check-integration integration_cleanup

check_environment:
ifndef BQ_REGION
	$(error BQ_REGION is undefined)
endif
ifndef BQ_PROJECT
	$(error BQ_PROJECT is undefined)
endif
ifndef BQ_DATASET
	$(error BQ_DATASET is undefined)
endif
ifndef BQ_BUCKET_PUBLIC
	$(error BQ_BUCKET_PUBLIC is undefined)
endif
ifndef BQ_MODULE_CORE_LABEL
	$(error BQ_MODULE_CORE_LABEL is undefined)
endif

##################### STORAGE FILES #####################

storage_upload: $(BQ_LIBRARY) check_environment
	$(GSUTIL) cp -r $(BQ_LIBRARY) $(BQ_BUCKET_PUBLIC)$(BQ_DATASET)/

storage_remove: check_environment
	$(GSUTIL) rm -rf $(BQ_BUCKET_PUBLIC)$(BQ_DATASET)/

##################### BIGQUERY DATASET #####################

dataset_create: check_environment
	$(BQ) --project_id $(BQ_PROJECT) show $(BQ_DATASET) 2>/dev/null 1>/dev/null || \
		$(BQ) mk -d --description "$(BQ_DATASET) module" -label $(BQ_MODULE_CORE_LABEL) $(BQ_PROJECT):$(BQ_DATASET)

dataset_remove: check_environment
	$(BQ) rm -r -f -d $(BQ_PROJECT):$(BQ_DATASET)

REPLACEMENTS = 	-e 's!%BQ_PROJECT%!$(BQ_PROJECT)!g' \
		-e 's!%BQ_DATASET%!$(BQ_DATASET)!g' \
		-e 's!%BQ_LIBRARY_BUCKET%!$(BQ_LIBRARY_BUCKET)!g'

dataset_deploy: check_environment
	for n in $(sort $(wildcard sql/*.sql)); do \
		$(SED) $(REPLACEMENTS) $$n | $(BQ) -q --project_id $(BQ_PROJECT) query --use_legacy_sql=false || exit; \
	done

##################### DEPLOY #####################

deploy: check_environment
	$(MAKE) storage_upload dataset_create
	$(MAKE) dataset_deploy
ifdef BQ_PERMISSIONS
	../../tools/set_module_permissions.sh
endif

##################### INTEGRATION TESTS #####################

test-integration: check_environment
	$(MAKE) deploy
	yarn test:integration || ($(MAKE) integration_cleanup && exit 1)
	$(MAKE) integration_cleanup

# Note, on failure we add a explicit sleep to wait until all resources are unused before retrying
integration_cleanup: check_environment
ifeq ($(POST_INTEGRATION_CLEANUP),1)
	$(MAKE) storage_remove
	$(MAKE) dataset_remove || ((sleep 5 && $(MAKE) dataset_remove) || exit 1)
endif

ENABLED_BQ ?= 0

.PHONY: all build check check-integration check-linter clean deploy linter

all build:
	yarn build

lint:
	yarn lint

test-unit:
	yarn test:unit

clean:
	yarn clean