# Makefile for Snowflake

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

DIST_DIR ?= $(ROOT_DIR)/dist
BUILD_DIR ?= $(ROOT_DIR)/build
COMMON_DIR = $(ROOT_DIR)/common

include $(COMMON_DIR)/Makefile

.SILENT:

.PHONY: help lint build deploy test remove clean create-package

help:
	echo "Available targets: lint build deploy test remove clean create-package"

lint:
	$(MAKE) lint-libraries
	$(MAKE) lint-modules
	$(MAKE) lint-common

lint-libraries:
	$(MAKE) -C libraries/javascript lint

lint-modules:
	$(MAKE) -C modules lint

lint-common: $(NODE_MODULES_DEV)
	echo "Linting common..."
	PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
	eslint --config $(ROOT_DIR)/../../.eslintrc.js $(COMMON_DIR)/*.js --fix

build:
	rm -rf $(BUILD_DIR)
	$(MAKE) build-libraries
	$(MAKE) build-modules

build-libraries:
	$(MAKE) -C libraries/javascript build

build-modules:
	mkdir -p $(BUILD_DIR)
	$(MAKE) -C modules build
	cp modules/build/modules.sql $(BUILD_DIR)

deploy: build
	$(MAKE) deploy-modules

deploy-modules:
	$(MAKE) -C modules deploy

test:
	$(MAKE) test-libraries
	$(MAKE) test-modules

test-libraries:
	$(MAKE) -C libraries/javascript test

test-modules:
	$(MAKE) -C modules test

remove:
	$(MAKE) remove-modules

remove-modules:
	$(MAKE) -C modules remove

clean:
	rm -rf $(DIST_DIR) $(BUILD_DIR)
	$(MAKE) clean-libraries
	$(MAKE) clean-modules

clean-libraries:
	$(MAKE) -C libraries/javascript clean

clean-modules:
	$(MAKE) -C modules clean

create-package:
	$(MAKE) build production=1

	$(eval PACKAGE_VERSION ?= $(shell cat $(ROOT_DIR)/version))
	$(eval PACKAGE_FULL_NAME = $(SF_LIBRARY_DEFAULT)-$(PACKAGE_VERSION))

	rm -rf $(DIST_DIR)
	mkdir -p $(DIST_DIR)/$(PACKAGE_FULL_NAME)
	cp -r $(BUILD_DIR)/* $(DIST_DIR)/$(PACKAGE_FULL_NAME)/

	cd $(DIST_DIR) && zip -r $(PACKAGE_FULL_NAME).zip . && cd ..
