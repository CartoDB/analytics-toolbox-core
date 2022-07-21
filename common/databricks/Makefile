# Makefile for Databricks modules

CLOUD = databricks

ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

.SILENT:

.PHONY: help lint lint-fix install build test-unit test-integration test-integration-full deploy clean clean-deploy serialize-module serialize-functions

help:
	echo "Please choose one of the following targets: lint, lint-fix, install, build, test-unit, test-integration, test-integration-full, deploy, clean, clean-deploy, serialize-module, serialize-functions"


lint: 
	(cd "${ROOT_DIR}/../../clouds/databricks" && exec sbt "scalafix --check")

lint-fix: $(NODE_MODULES_DEV)
	(cd "${ROOT_DIR}/../../clouds/databricks" && exec sbt scalafix)

install: 
	(cd "${ROOT_DIR}/../../clouds/databricks" && exec sbt compile)

build: 
	echo "TODO OK ${ROOT_DIR}/../../modules/databricks"; \
	(cd "${ROOT_DIR}/../../clouds/databricks" && exec sbt assembly)

test-unit:
	(cd "${ROOT_DIR}/../../clouds/databricks" && exec sbt test)

clean:
	(cd "${ROOT_DIR}/../../clouds/databricks" && exec sbt clean)

clean-deploy: check
ifdef MODULE_DEPS
	if [ "$(DEPLOY_DEPS)" = "1" ]; then \
		for module_dep in $(MODULE_DEPS); do \
			$(MAKE) -C $(MODULE_DEPS_DIR)/modules/$$module_dep/$(CLOUD) clean-deploy || exit 1; \
		done \
	fi;
endif
	$(MAKE) storage-remove
	$(MAKE) dataset-remove || ((sleep 5 && $(MAKE) dataset-remove) || exit 1)

storage-upload:
	$(MAKE) build
	$(GSUTIL) cp -r $(BQ_LIBRARY) $(BQ_LIBRARY_BUCKET)

storage-remove:
	if [ `$(GSUTIL) ls $(BQ_LIBRARY_BUCKET) 2>&1 | grep "$(BQ_LIBRARY_BUCKET)"` ]; then \
		$(GSUTIL) rm -r -f $(BQ_LIBRARY_BUCKET); \
	fi

dataset-create:
	$(BQ) show $(BQ_DEPLOY_DATASET) 2>/dev/null 1>/dev/null || \
		$(BQ) mk -d --description "$(BQ_DEPLOY_DATASET) module" -label $(BQ_MODULE_LABEL) $(BQ_DEPLOY_DATASET)
	$(MAKE) post-dataset-create

post-dataset-create:

dataset-remove:
	$(BQ) rm -r -f -d $(BQ_DEPLOY_DATASET)

dataset-deploy:
	for n in `CLOUD=$(CLOUD) node $(SCRIPTS_DIR)/sqlsort.js`; do \
		echo Deploying $$n; \
		$(SED) $(REPLACEMENTS) $$n | $(BQ) query -q --format=json --use_legacy_sql=false --project_id=$(BQ_PROJECT) --dataset_id=$(BQ_DEPLOY_DATASET) || exit 1; \
	done
	$(SED) $(REPLACEMENTS) $(COMMON_DIR)/VERSION.sql | $(BQ) query -q --format=json --use_legacy_sql=false --project_id=$(BQ_PROJECT) --dataset_id=$(BQ_DEPLOY_DATASET) || exit 1

serialize-module:: build
	rm -f $(DIST_DIR)/module.sql
	rm -f $(DIST_DIR)/module-header.sql
	rm -f $(DIST_DIR)/module-footer.sql
	touch $(DIST_DIR)/module-header.sql
	if [ "$(PACKAGE_TYPE)" = "CORE" ]; then \
		$(SED) $(REPLACEMENTS_PKG) $(COMMON_DIR)/DROP_FUNCTIONS.sql >> $(DIST_DIR)/module-header.sql; \
	fi
	for n in `CLOUD=$(CLOUD) node $(SCRIPTS_DIR)/sqlsort.js`; do \
	  	$(SED) $(REPLACEMENTS_PKG) $$n >> $(DIST_DIR)/module.sql; \
		echo "" >> $(DIST_DIR)/module.sql; \
	done
	$(SED) $(REPLACEMENTS_PKG) $(COMMON_DIR)/VERSION.sql >> $(DIST_DIR)/module-footer.sql;

serialize-functions:
	mkdir -p $(DIST_DIR)
	rm -f $(DIST_DIR)/funct_names.csv
	MODULE=$(MODULE) node $(SCRIPTS_DIR)/sqlfunctions.js >> $(DIST_DIR)/funct_names.csv

check:
ifndef BQ_REGION
	$(error BQ_REGION is undefined)
endif
ifndef BQ_PROJECT
	$(error BQ_PROJECT is undefined)
endif
ifndef BQ_BUCKET
	$(error BQ_BUCKET is undefined)
endif