# Makefile for Databricks modules

CLOUD = databricks

ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

CLOUD_DIR := $(ROOT_DIR)
SCALA_DIR := $(ROOT_DIR)/libraries/scala
COMMON_DIR := $(CLOUD_DIR)/common
JAR_DIR = $(SCALA_DIR)/core/target/scala-2.12
JAR_DEPLOY_PATH = dbfs:/FileStore/jars-carto/$(DB_DATASET_PREFIX)carto
SQL_DEPLOY_PATH = /Shared/$(DB_DATASET_PREFIX)carto
ENV_DIR ?= $(ROOT_DIR)/../..
SQL_PATH = $(JAR_DIR)/classes/sql/createUDFs.sql



ifneq (,$(wildcard $(ENV_DIR)/.env))
	include $(ENV_DIR)/.env
	export $(shell sed 's/=.*//' $(ENV_DIR)/.env)
endif

.SILENT:

.PHONY: help lint lint-fix install build test-unit test-integration test-integration-full deploy clean clean-deploy check

help:
	echo "Please choose one of the following targets: lint, lint-fix, install, build, test-unit, test-integration, test-integration-full, deploy, clean, clean-deploy, serialize-module, serialize-functions"


lint: 
	(cd "$(SCALA_DIR)" && exec sbt "scalafix --check")

lint-fix: 
	(cd "$(SCALA_DIR)" && exec sbt "scalafix")

install: 
	(cd "$(SCALA_DIR)" && exec sbt compile)

build: 
	echo "Generating assembly jar"; \
	(cd "$(SCALA_DIR)" && exec sbt assembly)

test-unit:
	(cd "$(SCALA_DIR)" && exec sbt test)

clean:
	(cd "$(SCALA_DIR)" && exec sbt clean)

check:
ifndef DB_CLUSTER_ID
	$(error DB_CLUSTER_ID env variable is mandatory)
endif
check-extra:
ifndef RS_HOST
	$(error RS_HOST is undefined)
endif
ifndef RS_PASSWORD
	$(error RS_PASSWORD is undefined)
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
	sed -i'.bkp' '1s/^/USE ${DB_SCHEMA};\n/' $(SQL_PATH)
	databricks workspace mkdirs $(SQL_DEPLOY_PATH)
	databricks workspace import --overwrite --language SQL $(SQL_PATH) $(SQL_DEPLOY_PATH)/createUDFs

create-udfs:
	sed -e 's/@@DB_CLUSTER_ID@@/${DB_CLUSTER_ID}/g' -e 's!@@SQLPath@@!$(SQL_DEPLOY_PATH)/createUDFs!g' $(COMMON_DIR)/submit-run-template.json > $(COMMON_DIR)/submit-run.json
	databricks runs submit --json-file $(COMMON_DIR)/submit-run.json

# TODO: check if the job finishes ok

deploy: check upload-jars
	echo "Installing libraries"
	databricks libraries install --cluster-id $(DB_CLUSTER_ID) --jar $(JAR_DEPLOY_PATH)/analyticstoolbox-assembly-SNAPSHOT.jar
	echo "Libraries installed "
	$(MAKE) upload-sql		
	echo "Installing functions"
	$(MAKE) create-udfs

venv:
	virtualenv -p python3 $(COMMON_DIR)/venv -q
	. $(COMMON_DIR)/venv/bin/activate && \
	python -m pip install -U pip -q && \
	pip install -r $(COMMON_DIR)/requirements.txt -q && \
	deactivate

test-integration: check check-extra venv
	. $(COMMON_DIR)/venv/bin/activate && \
	for module in `ls $(CLOUD_DIR)/modules`; do \
		echo "> Module $${module}"; \
		pytest -rP -p no:warnings modules/$${module}; \
	done; \
	deactivate
	
test-integration-full:
	$(MAKE) deploy
	$(MAKE) test-integration || ($(MAKE) clean-deploy && exit 1)
	$(MAKE) clean-deploy

clean-deploy:
	echo "WIP"

check:
ifndef DB_CLUSTER_ID
	$(error DB_CLUSTER_ID env variable is mandatory)
endif

check-extra:
ifndef DATABRICKS_SERVER_HOSTNAME
	$(error DATABRICKS_SERVER_HOSTNAME is undefined)
endif
ifndef DATABRICKS_HTTP_PATH
	$(error DATABRICKS_HTTP_PATH is undefined)
endif
ifndef DATABRICKS_TOKEN
	$(error DATABRICKS_TOKEN is undefined)
endif