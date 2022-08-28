# Makefile for Snowflake JavaScript library

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

LIBS_DIR ?= $(ROOT_DIR)/libs
SRC_DIR ?= $(ROOT_DIR)/src
TEST_DIR ?= $(ROOT_DIR)/test
BUILD_DIR ?= $(ROOT_DIR)/build
ENV_DIR ?= $(ROOT_DIR)/../..
ESLINTRC_DIR ?= $(ROOT_DIR)/../../../..
COMMON_DIR ?= $(ROOT_DIR)/../../common

include $(COMMON_DIR)/Makefile

.SILENT:

.PHONY: help lint build deploy test remove clean

help:
	echo "Please choose one of the following targets: lint build deploy test remove clean"

lint: $(NODE_MODULES_DEV)
	echo "Linting libraries..."
	PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
	eslint --config $(ESLINTRC_DIR)/.eslintrc.js $(LIBS_DIR) $(SRC_DIR) $(TEST_DIR) --fix

build:
	echo "Building libraries..."
	rm -rf $(BUILD_DIR)
	mkdir $(BUILD_DIR)
	$(MAKE) build-libs

build-libs: $(NODE_MODULES) $(NODE_MODULES_DEV)
	for f in $(shell $(COMMON_DIR)/list_libraries.js --all=$(all) --diff=$(diff) --modules=$(modules) --functions=$(functions)); do \
		NAME=$${f}Lib \
		PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
		INPUT=$(LIBS_DIR)/$${f}.js \
		OUTPUT=$(BUILD_DIR)/$${f}.js \
		rollup --config $(COMMON_DIR)/rollup.config.js $(BUILD_PARAMS); \
	done \

test:
	echo "Testing libraries..."
	UNIT_TEST=1 $(MAKE) build all=1
	PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
	jest --testTimeout=30000 --bail --verbose $(TEST_DIR)/$(test)

clean:
	echo "Cleaning libraries..."
	rm -rf $(BUILD_DIR) $(NODE_MODULES) $(NODE_MODULES_DEV)
	yarn -s cache clean
