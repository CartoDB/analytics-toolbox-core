# Makefile for Bigquery JavaScript library

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

LIBS_DIR ?= $(ROOT_DIR)/libs
LIBS_DIRS ?= $(ROOT_DIR)/libs
SRC_DIR ?= $(ROOT_DIR)/src
TEST_DIR ?= $(ROOT_DIR)/test
BUILD_DIR ?= $(ROOT_DIR)/build
ENV_DIR ?= $(ROOT_DIR)/../..
MODULES_DIR ?= $(ROOT_DIR)/../../modules
MODULES_DIRS ?= $(ROOT_DIR)/../../modules
ESLINTRC_DIR ?= $(ROOT_DIR)/../../../..
COMMON_DIR = $(ROOT_DIR)/../../common

ifeq ($(testall),1)
BAIL=
else
BAIL=--bail
endif

include $(COMMON_DIR)/Makefile

.SILENT:

.PHONY: help lint build deploy test clean

help:
	echo "Please choose one of the following targets: lint build deploy test clean"

lint: $(NODE_MODULES_DEV)
	echo "Linting libraries..."
	echo "- Lint JavaScript files"
	PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
	eslint --config $(ESLINTRC_DIR)/.eslintrc.js $(LIBS_DIR) $(SRC_DIR) $(TEST_DIR) --fix

build:
	echo "Building libraries..."
	rm -rf $(BUILD_DIR)
	mkdir $(BUILD_DIR)
	$(MAKE) build-libs
ifdef MAKE_LIB
	echo "Building extra libraries $(SRC_DIR)/$(MAKE_LIB)..."
	$(MAKE) -C $(SRC_DIR)/$(MAKE_LIB)
endif

build-libs: build-install $(NODE_MODULES_DEV)
ifdef UNIT_TEST
	$(COMMON_DIR)/list_libraries.js $(MODULES_DIR) --all --makelib=$(MAKE_LIB) 1>/dev/null # Check errors
	for f in `$(COMMON_DIR)/list_libraries.js $(MODULES_DIR) --all --makelib=$(MAKE_LIB)`; do \
		NAME=$${f}Lib \
		PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
		DIRS=$(LIBS_DIR) \
		FILENAME=$${f}.js \
		OUTPUT=$(BUILD_DIR)/$${f}.js \
		rollup --config $(COMMON_DIR)/rollup.config.js $(BUILD_PARAMS); \
	done
else
	$(COMMON_DIR)/list_libraries.js $(MODULES_DIRS) --diff="$(diff)" --modules=$(modules) --functions=$(functions) --nodeps=$(nodeps) --makelib=$(MAKE_LIB) 1>/dev/null # Check errors
	for f in `$(COMMON_DIR)/list_libraries.js $(MODULES_DIRS) --diff="$(diff)" --modules=$(modules) --functions=$(functions) --nodeps=$(nodeps) --makelib=$(MAKE_LIB)`; do \
		NAME=$${f}Lib \
		PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
		DIRS=$(LIBS_DIRS) \
		FILENAME=$${f}.js \
		OUTPUT=$(BUILD_DIR)/$${f}.js \
		rollup --config $(COMMON_DIR)/rollup.config.js $(BUILD_PARAMS); \
	done
endif

build-install:
	for d in $(shell echo $(LIBS_DIRS) | tr "," "\n"); do \
		yarn -s --update-checksums --cwd $$d/..; \
	done;

deploy: check build
	echo "Deploying libraries..."
	$(COMMON_DIR)/list_libraries.js $(MODULES_DIRS) --diff="$(diff)" --modules=$(modules) --functions=$(functions) --nodeps=$(nodeps) --makelib=$(MAKE_LIB) 1>/dev/null # Check errors
	for f in `$(COMMON_DIR)/list_libraries.js $(MODULES_DIRS) --diff="$(diff)" --modules=$(modules) --functions=$(functions) --nodeps=$(nodeps) --makelib=$(MAKE_LIB)`; do \
		$(GSUTIL) cp -r $(BUILD_DIR)/$${f}.js $(BQ_LIBRARY_BUCKET)_$${f}.js; \
	done
	# Provisional for WASM version of tiler
ifdef MAKE_LIB
	echo "Deploying tiler library..."
	$(GSUTIL) cp -r $(BUILD_DIR)/index_$(MAKE_LIB).js $(BQ_LIBRARY_TILER_BUCKET)
endif

test:
	echo "Testing libraries..."
	UNIT_TEST=1 $(MAKE) build
	PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
	jest --testTimeout=30000 $(BAIL) --verbose $(TEST_DIR)/$(test)
ifdef MAKE_LIB
	echo "Testing extra libraries $(TEST_DIR)/$(MAKE_LIB)..."
	$(MAKE) -C $(TEST_DIR)/$(MAKE_LIB) test
endif

clean:
	echo "Cleaning libraries..."
	rm -rf $(BUILD_DIR) $(NODE_MODULES_DEV)
	for d in $(shell echo $(LIBS_DIRS) | tr "," "\n"); do \
		rm -rf $$d/../node_modules; \
	done;
	yarn -s cache clean
