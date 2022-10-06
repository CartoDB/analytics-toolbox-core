# Makefile for Databricks scala library

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

ENV_DIR ?= $(ROOT_DIR)/../..
PRODUCT ?= core
COMMON_DIR = $(ROOT_DIR)/../../common
SCALA_DIR ?= $(ROOT_DIR)
JAR_DIR ?= $(SCALA_DIR)/$(PRODUCT)/target/scala-2.12
JAR_DEPLOY_PATH = dbfs:/FileStore/jars-carto/$(DB_PREFIX)carto-$(PRODUCT)
SQL_PATH = $(JAR_DIR)/classes/sql/createUDFs.sql
NEWLINE = ${'\n'} # some versions of sed don't support \n for a newline

include $(COMMON_DIR)/Makefile

.SILENT:

.PHONY: help lint build deploy test remove clean publish-local-core ci-release-core create-headers check-headers

help:
	echo "Please choose one of the following targets: help lint build deploy test remove clean publish-local-core ci-release-core create-headers check-headers"

lint:
	echo "- Linting libraries..."
	(cd "$(SCALA_DIR)" && exec sbt "scalafix")

install:
	(cd "$(SCALA_DIR)" && exec sbt compile)

build:
	echo "- Generating assembly jar"
	(cd "$(SCALA_DIR)" && exec sbt assembly)

publish-local-core:
	echo "- Publishing libraries in local repository"
	(cd "$(ROOT_DIR)" && exec sbt publishLocal)

ci-release-core:
	echo "- Publishing libraries in snapshot repository"
	(cd "$(ROOT_DIR)" && exec sbt ci-release)

create-headers:
	echo "- Adding headers with license"
	(cd "$(SCALA_DIR)" && exec sbt headerCreate)

check-headers:
	echo "- Adding headers with license"
	(cd "$(SCALA_DIR)" && exec sbt headerCheck)

deploy: check
	echo "Deploying libraries..."
	$(MAKE) upload-jars
	$(MAKE) install-jars

upload-jars: clean build
	echo "- Uploading jars"
	dbfs mkdirs $(JAR_DEPLOY_PATH)
	dbfs cp --overwrite $(JAR_DIR)/$(PRODUCT)-assembly-*.jar $(JAR_DEPLOY_PATH)/analyticstoolbox-$(PRODUCT)-assembly.jar
	echo "- Jars uploaded"

install-jars:
	echo "- Installing jars"
	databricks libraries install --cluster-id $(DB_CLUSTER_ID) --jar $(JAR_DEPLOY_PATH)/analyticstoolbox-$(PRODUCT)-assembly.jar
	echo "- Libraries installed"

test:
	echo "Testing libraries..."
	python3 $(COMMON_DIR)/python_utils/create_modules_sql.py $(SCALA_DIR)/$(PRODUCT)/src/main/resources/sql/modules.sql
	(cd "$(SCALA_DIR)" && exec sbt test)

remove: check
	echo "Removing libraries..."
	databricks libraries uninstall --cluster-id $(DB_CLUSTER_ID) --jar $(JAR_DEPLOY_PATH)/analyticstoolbox-$(PRODUCT)-assembly.jar
	dbfs rm -r $(JAR_DEPLOY_PATH)/

clean:
	echo "Cleaning libraries..."
	(cd "$(SCALA_DIR)" && exec sbt clean)
