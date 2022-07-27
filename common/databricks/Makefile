# Makefile for Databricks modules

CLOUD = databricks

ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
CLOUD_DIR := $(ROOT_DIR)/../../clouds/$(CLOUD)
JAR_DIR = $(CLOUD_DIR)/core/target/scala-2.12
JAR_DEPLOY_PATH = dbfs:/FileStore/jars-carto/$(DB_DATASET_PREFIX)carto
SQL_DEPLOY_PATH = /Shared/$(DB_DATASET_PREFIX)carto
ENV_DIR ?= $(ROOT_DIR)/../..
SQL_PATH = $(JAR_DIR)/classes/sql/createUDFs.sql



ifneq (,$(wildcard $(ENV_DIR)/.env))
	include $(ENV_DIR)/.env
	export $(shell sed 's/=.*//' $(ENV_DIR)/.env)
endif

#.SILENT:

.PHONY: help lint lint-fix install build test-unit test-integration test-integration-full deploy clean clean-deploy check

help:
	echo "Please choose one of the following targets: lint, lint-fix, install, build, test-unit, test-integration, test-integration-full, deploy, clean, clean-deploy, serialize-module, serialize-functions"


lint: 
	(cd "$(CLOUD_DIR)" && exec sbt "scalafix --check")

lint-fix: 
	(cd "$(CLOUD_DIR)" && exec sbt "scalafix")

install: 
	(cd "$(CLOUD_DIR)" && exec sbt compile)

build: 
	echo "TODO OK $(CLOUD_DIR)"; \
	(cd "$(CLOUD_DIR)" && exec sbt assembly)

test-unit:
	(cd "$(CLOUD_DIR)" && exec sbt test)

clean:
	(cd "$(CLOUD_DIR)" && exec sbt clean)

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


check:
ifndef DB_CLUSTER_ID
	$(error DB_CLUSTER_ID env variable is mandatory)
endif


upload-jars: clean build
	echo "Uploading jars"
	dbfs mkdirs $(JAR_DEPLOY_PATH)
	dbfs cp --overwrite $(JAR_DIR)/core-assembly-*-SNAPSHOT.jar $(JAR_DEPLOY_PATH)/analyticstoolbox-assembly-SNAPSHOT.jar
	echo "Jars uploaded"

upload-sql:
ifndef DB_SCHEMA
	echo "Databricks schema not defined, using default"
	$(eval DB_SCHEMA := default)
	echo $(DB_SCHEMA)
endif
	sed -i '.bkp' '1s/^/USE ${DB_SCHEMA};\n/' $(SQL_PATH)
	databricks workspace mkdirs $(SQL_DEPLOY_PATH)
	databricks workspace import --overwrite --language SQL $(SQL_PATH) $(SQL_DEPLOY_PATH)/createUDFs

create-udfs:
	sed -e 's/@@DB_CLUSTER_ID@@/${DB_CLUSTER_ID}/g' -e 's!@@SQLPath@@!$(SQL_DEPLOY_PATH)/createUDFs!g' $(ROOT_DIR)/submit-run-template.json > $(ROOT_DIR)/submit-run.json
	databricks runs submit --json-file $(ROOT_DIR)/submit-run.json

# TODO: check if the job finishes ok

deploy: check upload-jars
	echo "Installing libraries"
	databricks libraries install --cluster-id $(DB_CLUSTER_ID) --jar $(JAR_DEPLOY_PATH)/analyticstoolbox-assembly-SNAPSHOT.jar
	echo "Libraries installed "
	$(MAKE) upload-sql
	$(MAKE) create-udfs

test-integration:
	echo "WIP"
	
test-integration-full:
	echo "WIP"

clean-deploy:
	echo "WIP"
