# Programs
SED ?= sed
GREP ?= grep
BQ ?= bq
GSUTIL ?= gsutil

# Deployment variables
SKEL_BQ_BUCKET ?= $(BQ_BUCKET)
SKEL_BQ_LIBRARY ?= $(SKEL_BQ_BUCKET)$(SKEL_BQ_DATASET)/skel_library.js

check_environment:
ifndef BQ_PROJECTID
	$(error BQ_PROJECTID is undefined)
endif
ifndef SKEL_BQ_DATASET
	$(error SKEL_BQ_DATASET is undefined)
endif
ifndef SKEL_BQ_BUCKET
	$(error BQ_BUCKET is undefined)
endif

../$(SKEL_LIBRARY):
	$(MAKE) -C .. all

all:

clean:
	$(MAKE) -C test/ $@


../skel_library.js:
	$(MAKE) -C .. all

##################### STORAGE FILES #####################
storage_upload: ../skel_library.js check_environment
	$(GSUTIL) cp -r ../skel_library.js $(SKEL_BQ_BUCKET)$(SKEL_BQ_DATASET)/

storage_remove: check_environment
	$(GSUTIL) rm -rf $(SKEL_BQ_BUCKET)$(SKEL_BQ_DATASET)/

##################### BIGQUERY DATASET #####################

dataset_create: check_environment
	$(BQ) --project_id $(BQ_PROJECTID) show $(SKEL_BQ_DATASET) 2>/dev/null 1>/dev/null || \
		${BQ} mk -d --description "SKEL Dataset" $(BQ_PROJECTID):$(SKEL_BQ_DATASET)

dataset_remove: check_environment
	${BQ} rm -r -f -d $(BQ_PROJECTID):$(SKEL_BQ_DATASET)

REPLACEMENTS = 	-e 's!@@BQ_PROJECTID@@!$(BQ_PROJECTID)!g' \
		-e 's!@@SKEL_BQ_DATASET@@!$(SKEL_BQ_DATASET)!g' \
		-e 's!@@SKEL_BQ_LIBRARY@@!$(SKEL_BQ_LIBRARY)!g'

dataset_deploy: check_environment
	for n in $(wildcard sql/*.sql); do \
		$(SED) $(REPLACEMENTS) $$n | $(BQ) -q --project_id $(BQ_PROJECTID) query --use_legacy_sql=false || exit; \
	done

##################### DEPLOY #####################
deploy: check_environment
	$(MAKE) storage_upload dataset_create dataset_deploy

##################### INTEGRATION TESTS #####################
check_integration: check_environment
	$(MAKE) deploy
	$(MAKE) -C test/ $@ || ($(MAKE) integration_cleanup && exit 1)
	$(MAKE) integration_cleanup

# Note, on failure we add a explicit sleep to wait until all resources are unused before retrying
integration_cleanup: check_environment
ifeq ($(POST_INTEGRATION_CLEANUP),1)
	$(MAKE) storage_remove
	$(MAKE) dataset_remove || ((sleep 5 && $(MAKE) dataset_remove) || exit 1)
endif
