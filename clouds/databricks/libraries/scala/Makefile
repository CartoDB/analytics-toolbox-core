# Makefile for Databricks scala library

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

COMMON_DIR ?= $(ROOT_DIR)/../../common
SCALA_DIR := $(ROOT_DIR)
JAR_DIR = $(SCALA_DIR)/core/target/scala-2.12
JAR_DEPLOY_PATH = dbfs:/FileStore/jars-carto/$(DB_DATASET_PREFIX)carto

include $(COMMON_DIR)/Makefile

#.SILENT:

.PHONY: lint lint-fix build deploy test remove clean

help:
	echo "Please choose one of the following targets: lint lint-fix build deploy test remove clean"

lint: 
	(cd "$(SCALA_DIR)" && exec sbt "scalafix --check")

lint-fix: 
	(cd "$(SCALA_DIR)" && exec sbt "scalafix")

install: 
	(cd "$(SCALA_DIR)" && exec sbt compile)

build: 
	echo "Generating assembly jar"; \
	(cd "$(SCALA_DIR)" && exec sbt assembly)

test:
	(cd "$(SCALA_DIR)" && exec sbt test)

clean:
	(cd "$(SCALA_DIR)" && exec sbt clean)

upload-jars: clean build
	echo "Uploading jars"
	dbfs mkdirs $(JAR_DEPLOY_PATH)
	dbfs cp --overwrite $(JAR_DIR)/core-assembly-*-SNAPSHOT.jar $(JAR_DEPLOY_PATH)/analyticstoolbox-assembly-SNAPSHOT.jar
	echo "Jars uploaded"

deploy: check
	$(MAKE) upload-jars
	echo "Installing libraries"
	databricks libraries install --cluster-id $(DB_CLUSTER_ID) --jar $(JAR_DEPLOY_PATH)/analyticstoolbox-assembly-SNAPSHOT.jar
	echo "Libraries installed "
	
	$(MAKE) deploy-libraries
	$(MAKE) remove-libraries

remove:
	echo "WIP"
