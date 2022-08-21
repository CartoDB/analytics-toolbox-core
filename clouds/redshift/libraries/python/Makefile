# Makefile for Redshift Python library

ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

LIB_DIR ?= $(ROOT_DIR)/lib
TEST_DIR ?= $(ROOT_DIR)/test
BUILD_DIR ?= $(ROOT_DIR)/build
ENV_DIR ?= $(ROOT_DIR)/../..
COMMON_DIR ?= $(ROOT_DIR)/../../common

include $(COMMON_DIR)/Makefile

LIBS_URL ?= https://<URL>/libs

.SILENT:

.PHONY: help lint build deploy test remove clean

help:
	echo "Please choose one of the following targets: lint build deploy test remove clean"

lint: venv3
	echo "Linting libraries..."
	$(VENV3_BIN)/brunette $(LIB_DIR) $(TEST_DIR) --line-length=88 --single-quotes --quiet
	$(VENV3_BIN)/flake8 $(LIB_DIR) --enable-extensions Q0 --docstring-convention numpy --ignore=D100,D103,D104,F401,F403
	$(VENV3_BIN)/flake8 $(TEST_DIR) --ignore=D100,D103,D104

build:
	echo "Building libraries..."
	rm -rf $(BUILD_DIR)
	mkdir $(BUILD_DIR)
	$(MAKE) build-library
	$(MAKE) build-dependencies
	$(MAKE) build-libraries-sql

build-library: check
	mkdir -p $(BUILD_DIR)/libs/$(RS_LIBRARY)
	rsync -a --prune-empty-dirs --include '*/' --include '*.py' --exclude '*'  lib/ $(BUILD_DIR)/libs/$(RS_LIBRARY)/
	cd $(BUILD_DIR)/libs && zip -r $(RS_LIBRARY)-1.0.0.zip *
	rm -rf $(BUILD_DIR)/libs/$(RS_LIBRARY)

build-dependencies: venv2
	mkdir -p $(BUILD_DIR)/libs
ifneq ("$(wildcard requirements.txt)","")
	. $(VENV2_BIN)/activate && \
	bash $(COMMON_DIR)/serialize_libraries.sh -f requirements.txt&& \
	deactivate
endif

build-libraries-sql:
ifeq ($(production),1)
	$(eval FROM = $(shell echo "$(LIBS_URL)"))
else
	$(eval FROM = $(shell echo "$(RS_BUCKET)"))
	$(eval CREDENTIALS = $(shell echo "CREDENTIALS 'aws_access_key_id=$(AWS_ACCESS_KEY_ID);aws_secret_access_key=$(AWS_SECRET_ACCESS_KEY)'"))
endif
	for f in $(notdir $(wildcard $(BUILD_DIR)/libs/*.zip)); do \
		LIBRARY_NAME=$$(echo $$f | sed -e 's/-.*//g'); \
		echo "CREATE OR REPLACE LIBRARY $$LIBRARY_NAME LANGUAGE plpythonu FROM '$(FROM)/$(notdir $$f)' $(CREDENTIALS);" >> $(BUILD_DIR)/libraries.sql; \
	done
	sort -u $(BUILD_DIR)/libraries.sql -o $(BUILD_DIR)/libraries.sql

deploy: build
	echo "Deploying libraries..."
	$(MAKE) copy-libraries
	$(MAKE) deploy-libraries
	$(MAKE) remove-libraries

copy-libraries:
	for f in $(wildcard $(BUILD_DIR)/libs/*.zip); do \
		aws s3 cp $$f $(RS_BUCKET) || exit 1; \
	done

deploy-libraries:
	$(VENV3_BIN)/python $(COMMON_DIR)/run_script.py $(BUILD_DIR)/libraries.sql

remove-libraries:
	for f in $(notdir $(wildcard $(BUILD_DIR)/libs/*.zip)); do \
		aws s3 rm $(RS_BUCKET)/$(basename $$f) || exit 1; \
	done

test: check venv2
	echo "Testing libraries..."
	$(VENV2_BIN)/pytest -rP -p no:warnings -vv $(TEST_DIR)/$(test)

remove: check venv3
	echo "Removing libraries..."
	$(VENV3_BIN)/python $(COMMON_DIR)/run_query.py "DROP LIBRARY $(RS_LIBRARY);"

clean:
	echo "Cleaning libraries..."
	rm -rf $(BUILD_DIR) $(VENV2_DIR) $(VENV3_DIR)

