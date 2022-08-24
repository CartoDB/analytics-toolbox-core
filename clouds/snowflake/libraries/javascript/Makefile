# Makefile for Snowflake JavaScript library

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

LIBS_DIR ?= $(ROOT_DIR)/libs
SRC_DIR ?= $(ROOT_DIR)/src
TEST_DIR ?= $(ROOT_DIR)/test
BUILD_DIR ?= $(ROOT_DIR)/build
ENV_DIR ?= $(ROOT_DIR)/../..
LINT_DIR ?= $(ROOT_DIR)/../../../..
COMMON_DIR ?= $(ROOT_DIR)/../../common

include $(COMMON_DIR)/Makefile

.SILENT:

.PHONY: help lint build deploy test remove clean

help:
	echo "Please choose one of the following targets: lint build deploy test remove clean"

lint: $(NODE_MODULES_DEV)
	echo "Linting libraries..."
	PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
	eslint --config $(LINT_DIR)/.eslintrc.js $(LIBS_DIR) $(SRC_DIR) $(TEST_DIR) --fix

build:
	echo "Building libraries..."
	rm -rf $(BUILD_DIR)
	mkdir $(BUILD_DIR)
	$(MAKE) build-libs

build-libs: $(NODE_MODULES) $(NODE_MODULES_DEV)
	for f in $(notdir $(basename $(shell find $(LIBS_DIR)/* -type f 2>/dev/null))); do \
		NAME=$${f}Lib \
		PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
		INPUT=$(LIBS_DIR)/$${f}.js \
		OUTPUT=$(BUILD_DIR)/$${f}.js \
		rollup --config $(COMMON_DIR)/rollup.config.js $(BUILD_PARAMS); \
	done \

test:
	echo "Testing libraries..."
	UNIT_TEST=1 $(MAKE) build
	PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
	jest $(TEST_DIR)/$(test) --testTimeout=30000

clean:
	echo "Cleaning libraries..."
	rm -rf $(BUILD_DIR) $(NODE_MODULES) $(NODE_MODULES_DEV)
	yarn -s cache clean
