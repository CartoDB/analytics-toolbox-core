# Programs
SED ?= sed
BQ ?= bq --location=$(BQ_REGION)
GSUTIL ?= gsutil

POST_INTEGRATION_CLEANUP ?= 1

# Deployment variables
S2_BQ_LIBRARY ?= $(BQ_BUCKET_PUBLIC)$(BQ_DATASET_S2)/s2_library.js

.PHONY: ../s2_library.js
../s2_library.js:
	$(MAKE) -C .. all

.PHONY: check_environment all check clean storage_upload storage_remove dataset_create dataset_remove dataset_deploy deploy check-integration integration_cleanup

check_environment:
ifndef BQ_REGION
	$(error BQ_REGION is undefined)
endif
ifndef BQ_PROJECTID
	$(error BQ_PROJECTID is undefined)
endif
ifndef BQ_DATASET_S2
	$(error BQ_DATASET_S2 is undefined)
endif
ifndef BQ_BUCKET_PUBLIC
	$(error BQ_BUCKET_PUBLIC is undefined)
endif

all check:

clean:
	$(MAKE) -C test/ $@

##################### STORAGE FILES #####################
storage_upload: ../s2_library.js check_environment
	$(GSUTIL) cp -r ../s2_library.js $(BQ_BUCKET_PUBLIC)$(BQ_DATASET_S2)/

storage_remove: check_environment
	$(GSUTIL) rm -rf $(BQ_BUCKET_PUBLIC)$(BQ_DATASET_S2)/

##################### BIGQUERY DATASET #####################

dataset_create: check_environment
	$(BQ) --project_id $(BQ_PROJECTID) show $(BQ_DATASET_S2) 2>/dev/null 1>/dev/null || \
		${BQ} mk -d --description "S2 Dataset" $(BQ_PROJECTID):$(BQ_DATASET_S2)

dataset_remove: check_environment
	${BQ} rm -r -f -d $(BQ_PROJECTID):$(BQ_DATASET_S2)

REPLACEMENTS = 	-e 's!@@BQ_PROJECTID@@!$(BQ_PROJECTID)!g' \
		-e 's!@@BQ_DATASET_S2@@!$(BQ_DATASET_S2)!g' \
		-e 's!@@S2_BQ_LIBRARY@@!$(S2_BQ_LIBRARY)!g'

dataset_deploy: check_environment
	for n in $(wildcard sql/*.sql); do \
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
