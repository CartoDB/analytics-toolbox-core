# Programs
SED ?= sed
BQ ?= bq --location=$(BQ_REGION)
GSUTIL ?= gsutil

POST_INTEGRATION_CLEANUP ?= 1

# Deployment variables
TURF_BQ_LIBRARY ?= $(BQ_BUCKET_PUBLIC)$(BQ_DATASET_TRANSFORMATION)/turf_library.js

.PHONY: ../turf_library.js
../turf_library.js:
	$(MAKE) -C .. all

.PHONY: check_environment all check clean storage_upload storage_remove dataset_create dataset_remove dataset_deploy deploy check-integration integration_cleanup

check_environment:
ifndef BQ_REGION
	$(error BQ_REGION is undefined)
endif
ifndef BQ_PROJECTID
	$(error BQ_PROJECTID is undefined)
endif
ifndef BQ_DATASET_TRANSFORMATION
	$(error BQ_DATASET_TRANSFORMATION is undefined)
endif
ifndef BQ_BUCKET_PUBLIC
	$(error BQ_BUCKET_PUBLIC is undefined)
endif

all check:

clean:
	$(MAKE) -C test/ $@

##################### STORAGE FILES #####################
storage_upload: ../turf_library.js check_environment
	$(GSUTIL) cp -r ../turf_library.js $(BQ_BUCKET_PUBLIC)$(BQ_DATASET_TRANSFORMATION)/

storage_remove: check_environment
	$(GSUTIL) rm -rf $(BQ_BUCKET_PUBLIC)$(BQ_DATASET_TRANSFORMATION)/

##################### BIGQUERY DATASET #####################

dataset_create: check_environment
	$(BQ) --project_id $(BQ_PROJECTID) show $(BQ_DATASET_TRANSFORMATION) 2>/dev/null 1>/dev/null || \
		${BQ} mk -d --description "TRANSFORMATION Dataset" $(BQ_PROJECTID):$(BQ_DATASET_TRANSFORMATION)

dataset_remove: check_environment
	${BQ} rm -r -f -d $(BQ_PROJECTID):$(BQ_DATASET_TRANSFORMATION)

REPLACEMENTS = 	-e 's!@@BQ_PROJECTID@@!$(BQ_PROJECTID)!g' \
		-e 's!@@BQ_DATASET_TRANSFORMATION@@!$(BQ_DATASET_TRANSFORMATION)!g' \
		-e 's!@@TURF_BQ_LIBRARY@@!$(TURF_BQ_LIBRARY)!g'

dataset_deploy: check_environment
	for n in $(sort $(wildcard sql/*.sql)); do \
		$(SED) $(REPLACEMENTS) $$n | $(BQ) -q --project_id $(BQ_PROJECTID) query --use_legacy_sql=false || exit; \
	done

##################### DEPLOY #####################
deploy: check_environment
	$(MAKE) storage_upload dataset_create
	$(MAKE) dataset_deploy

##################### INTEGRATION TESTS #####################
check-integration: check_environment
	$(MAKE) deploy
	$(MAKE) -C test/ $@ || ($(MAKE) integration_cleanup && exit 1)
	$(MAKE) integration_cleanup

# Note, on failure we add a explicit sleep to wait until all resources are unused before retrying
integration_cleanup: check_environment
ifeq ($(POST_INTEGRATION_CLEANUP),1)
	$(MAKE) storage_remove
	$(MAKE) dataset_remove || ((sleep 5 && $(MAKE) dataset_remove) || exit 1)
endif
