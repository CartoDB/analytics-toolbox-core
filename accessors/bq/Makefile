# Programs
SED ?= sed
BQ ?= bq --location=$(BQ_REGION)
GSUTIL ?= gsutil

POST_INTEGRATION_CLEANUP ?= 1

export BQ_PERMISSIONS_TARGET_DATASET = ${BQ_DATASET_ACCESSORS}

# Deployment variables
ACCESSORS_BQ_LIBRARY ?= $(BQ_BUCKET_PUBLIC)$(BQ_DATASET_ACCESSORS)/accessors_library.js

.PHONY: ../accessors_library.js
../accessors_library.js:
	$(MAKE) -C .. all

.PHONY: check_environment all check clean storage_upload storage_remove dataset_create dataset_remove dataset_deploy deploy check-integration integration_cleanup

check_environment:
ifndef BQ_REGION
	$(error BQ_REGION is undefined)
endif
ifndef BQ_PROJECTID
	$(error BQ_PROJECTID is undefined)
endif
ifndef BQ_DATASET_ACCESSORS
	$(error BQ_DATASET_ACCESSORS is undefined)
endif
ifndef BQ_BUCKET_PUBLIC
	$(error BQ_BUCKET_PUBLIC is undefined)
endif

all check:

clean:
	$(MAKE) -C test/ $@

##################### STORAGE FILES #####################
storage_upload: ../accessors_library.js check_environment
	$(GSUTIL) cp -r ../accessors_library.js $(BQ_BUCKET_PUBLIC)$(BQ_DATASET_ACCESSORS)/

storage_remove: check_environment
	$(GSUTIL) rm -rf $(BQ_BUCKET_PUBLIC)$(BQ_DATASET_ACCESSORS)/

##################### BIGQUERY DATASET #####################
dataset_create: check_environment
	$(BQ) --project_id $(BQ_PROJECTID) show $(BQ_DATASET_ACCESSORS) 2>/dev/null 1>/dev/null || \
		$(BQ) mk -d --description "ACCESSORS Dataset" $(BQ_PROJECTID):$(BQ_DATASET_ACCESSORS)

dataset_remove: check_environment
	$(BQ) rm -r -f -d $(BQ_PROJECTID):$(BQ_DATASET_ACCESSORS)

REPLACEMENTS = -e 's!@@BQ_PROJECTID@@!$(BQ_PROJECTID)!g' \
	-e 's!@@BQ_DATASET_ACCESSORS@@!$(BQ_DATASET_ACCESSORS)!g' \
	-e 's!@@ACCESSORS_BQ_LIBRARY@@!$(ACCESSORS_BQ_LIBRARY)!g'

dataset_deploy: check_environment
	for n in $(sort $(wildcard sql/*.sql)); do \
		$(SED) $(REPLACEMENTS) $$n | $(BQ) -q --project_id $(BQ_PROJECTID) query --use_legacy_sql=false || exit; \
	done

##################### DEPLOY #####################
deploy: check_environment
	$(MAKE) storage_upload
	$(MAKE) dataset_create
	$(MAKE) dataset_deploy
ifdef BQ_PERMISSIONS_ROLE
	../../tools/set_module_permissions.sh
endif

##################### INTEGRATION TESTS #####################
check-integration: check_environment
	$(MAKE) deploy
	$(MAKE) -C test/ $@ || ($(MAKE) integration_cleanup && exit 1)
	$(MAKE) integration_cleanup

# Note, on failure we add a explicit sleep to wait until all resources are unused before retrying
integration_cleanup: check_environment
ifeq ($(POST_INTEGRATION_CLEANUP), 1)
	$(MAKE) storage_remove
	$(MAKE) dataset_remove || ((sleep 5 && $(MAKE) dataset_remove) || exit 1)
endif