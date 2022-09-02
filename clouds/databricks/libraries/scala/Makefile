# Makefile for Databricks scala library

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

ENV_DIR ?= $(ROOT_DIR)/../..
COMMON_DIR = $(ROOT_DIR)/../../common
SCALA_DIR = $(ROOT_DIR)
JAR_DIR = $(SCALA_DIR)/core/target/scala-2.12
JAR_DEPLOY_PATH = dbfs:/FileStore/jars-carto/$(DB_PREFIX)carto
SQL_PATH = $(JAR_DIR)/classes/sql/createUDFs.sql

include $(COMMON_DIR)/Makefile

.SILENT:

.PHONY: help lint build deploy test remove clean

help:
	echo "Please choose one of the following targets: help lint build deploy test remove clean"

lint:
	echo "Linting libraries..."
	(cd "$(SCALA_DIR)" && exec sbt "scalafix")

install:
	(cd "$(SCALA_DIR)" && exec sbt compile)

build:
	echo "Building libraries..."
	echo "- Generating assembly jar"
	(cd "$(SCALA_DIR)" && exec sbt assembly)

deploy: check
	echo "Deploying libraries..."
	$(MAKE) upload-jars
	$(MAKE) install-jars
	$(MAKE) upload-sql
	$(MAKE) create-udfs

upload-jars: clean build
	echo "- Uploading jars"
	dbfs mkdirs $(JAR_DEPLOY_PATH)
	dbfs cp --overwrite $(JAR_DIR)/core-assembly-*.jar $(JAR_DEPLOY_PATH)/analyticstoolbox-assembly-SNAPSHOT.jar
	echo "- Jars uploaded"

install-jars:
	echo "- Installing jars"
	databricks libraries install --cluster-id $(DB_CLUSTER_ID) --jar $(JAR_DEPLOY_PATH)/analyticstoolbox-assembly-SNAPSHOT.jar
	echo "- Libraries installed"

upload-sql:
	echo "- Installing functions"
ifndef DB_SCHEMA
	echo "- Databricks schema not defined, using default"
	$(eval DB_SCHEMA := default)
endif
	sed -i'.bkp' '1s/^/USE ${DB_SCHEMA};\n/' $(SQL_PATH)
	databricks workspace mkdirs $(SQL_DEPLOY_PATH)
	databricks workspace import --overwrite --language SQL $(SQL_PATH) $(SQL_DEPLOY_PATH)/createUDFs

create-udfs:
	sed -e 's/@@DB_CLUSTER_ID@@/${DB_CLUSTER_ID}/g' -e 's!@@SQLPath@@!$(SQL_DEPLOY_PATH)/createUDFs!g' $(COMMON_DIR)/submit-run-template.json > $(COMMON_DIR)/submit-run.json
	databricks runs submit --json-file $(COMMON_DIR)/submit-run.json --wait
	echo "- Removing install script from the workspace"
	databricks workspace rm -r $(SQL_DEPLOY_PATH)

test:
	echo "Testing libraries..."
	(cd "$(SCALA_DIR)" && exec sbt test)

remove: check
	echo "Removing libraries..."
	databricks libraries uninstall --cluster-id $(DB_CLUSTER_ID) --jar $(JAR_DEPLOY_PATH)/analyticstoolbox-assembly-SNAPSHOT.jar
	dbfs rm $(JAR_DEPLOY_PATH)/analyticstoolbox-assembly-SNAPSHOT.jar

clean:
	echo "Cleaning libraries..."
	(cd "$(SCALA_DIR)" && exec sbt clean)
