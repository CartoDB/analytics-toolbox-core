# Makefile for Redshift Python library

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

LIB_DIR ?= $(ROOT_DIR)/lib
TEST_DIR ?= $(ROOT_DIR)/test
BUILD_DIR ?= $(ROOT_DIR)/build
ENV_DIR ?= $(ROOT_DIR)/../..
COMMON_DIR ?= $(ROOT_DIR)/../../common
LIB_DIRS ?= $(ROOT_DIR)/lib/
REQUIREMENTS_DIRS ?= requirements.txt
LIBS_URL ?= https://<URL>/libs
LIB_NAME = $(RS_LIBRARY)-1.0.0

include $(COMMON_DIR)/Makefile

.SILENT:

.PHONY: help lint build deploy test remove clean

help:
	echo "Please choose one of the following targets: lint build deploy test remove clean"

lint: venv3
	echo "Linting libraries..."
	$(VENV3_BIN)/brunette $(LIB_DIR) $(TEST_DIR) --line-length=88 --single-quotes --quiet
	$(VENV3_BIN)/flake8 $(LIB_DIR) --enable-extensions Q0 --docstring-convention numpy --ignore=D100,D103,D104,D205,D400,D407,F401,D411,F403,W503
	$(VENV3_BIN)/flake8 $(TEST_DIR) --ignore=D100,D103,D104,W503

build:
	echo "Building libraries..."
	rm -rf $(BUILD_DIR)
	mkdir $(BUILD_DIR)
	$(MAKE) build-library
	$(MAKE) build-dependencies
	$(MAKE) build-libraries-sql

build-library: check
	mkdir -p $(BUILD_DIR)/libs/$(RS_LIBRARY)
	rsync -a --prune-empty-dirs --include '*/' --include '*.py' --exclude '*' $(LIB_DIRS) $(BUILD_DIR)/libs/$(RS_LIBRARY)/
	cd $(BUILD_DIR)/libs && zip -r $(LIB_NAME).zip *
	rm -rf $(BUILD_DIR)/libs/$(RS_LIBRARY)

build-dependencies: venv2
	mkdir -p $(BUILD_DIR)/libs
	. $(VENV2_BIN)/activate && \
	for r in $(REQUIREMENTS_DIRS); do \
		bash $(COMMON_DIR)/serialize_libraries.sh -f $$r; \
	done && \
	deactivate

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

deploy: build
	echo "Deploying libraries..."
	$(MAKE) copy-libraries
	$(MAKE) deploy-libraries
	$(MAKE) remove-libraries

copy-libraries:
ifeq ("$(library)","carto")
	for f in $(wildcard $(BUILD_DIR)/libs/*.zip); do \
		if [ `echo $$f | grep $(RS_LIBRARY)` ]; then \
			aws s3 cp $$f $(RS_BUCKET) || exit 1; \
		fi \
	done
else
	for f in $(wildcard $(BUILD_DIR)/libs/*.zip); do \
		aws s3 cp $$f $(RS_BUCKET) || exit 1; \
	done
endif

deploy-libraries: venv3
ifeq ("$(library)","carto")
	FILTER=$(RS_LIBRARY) $(VENV3_BIN)/python $(COMMON_DIR)/run_script.py $(BUILD_DIR)/libraries.sql
else
	$(VENV3_BIN)/python $(COMMON_DIR)/run_script.py $(BUILD_DIR)/libraries.sql
endif

remove-libraries:
ifeq ("$(library)","carto")
	for f in $(notdir $(wildcard $(BUILD_DIR)/libs/*.zip)); do \
		if [ `echo $$f | grep $(RS_LIBRARY)` ]; then \
			aws s3 rm $(RS_BUCKET)/$(basename $$f) || exit 1; \
		fi \
	done
else
	for f in $(notdir $(wildcard $(BUILD_DIR)/libs/*.zip)); do \
		aws s3 rm $(RS_BUCKET)/$(basename $$f) || exit 1; \
	done
endif

test: check venv2
	echo "Testing libraries..."
	$(VENV2_BIN)/pytest -rP -p no:warnings -x -vv $(TEST_DIR)/$(test)

remove: check venv3
	echo "Removing libraries..."
	$(VENV3_BIN)/python $(COMMON_DIR)/run_query.py "DROP LIBRARY $(RS_LIBRARY);"

clean:
	echo "Cleaning libraries..."
	rm -rf $(BUILD_DIR) $(VENV2_DIR) $(VENV3_DIR)