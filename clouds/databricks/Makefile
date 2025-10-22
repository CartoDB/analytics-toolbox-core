# Makefile for Databricks

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

DIST_DIR ?= $(ROOT_DIR)/dist
BUILD_DIR ?= $(ROOT_DIR)/build
COMMON_DIR = $(ROOT_DIR)/common
PACKAGE_VERSION ?= $(shell cat $(ROOT_DIR)/version)
PACKAGE_NAME ?= carto-analytics-toolbox-core-databricks-$(PACKAGE_VERSION)

include $(COMMON_DIR)/Makefile

.SILENT:

.PHONY: help lint build deploy test remove clean

help:
	echo "Available targets: help lint build deploy test remove clean"

lint:
	$(MAKE) lint-modules
	$(MAKE) lint-common

lint-modules:
	$(MAKE) -C modules lint

lint-common: $(NODE_MODULES_DEV)
	echo "Linting common..."
	echo "- Lint Markdown files"
	PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
	markdownlint -f '*.md' --ignore node_modules --disable MD013 MD024 MD033 MD036 MD040 MD041 MD051 MD045 --

build:
	rm -rf $(BUILD_DIR)
	$(MAKE) build-modules

build-modules:
	mkdir -p $(BUILD_DIR)
	$(MAKE) -C modules build
	cp modules/build/modules.sql $(BUILD_DIR)/

deploy:
	$(MAKE) deploy-modules

deploy-modules:
	$(MAKE) -C modules deploy

test:
	$(MAKE) test-modules

test-modules:
	$(MAKE) -C modules test

remove:
	$(MAKE) remove-modules

remove-modules:
	$(MAKE) -C modules remove

clean:
	rm -rf $(DIST_DIR) $(BUILD_DIR)
	$(MAKE) clean-modules

clean-modules:
	$(MAKE) -C modules clean

create-package:
	echo "Creating package..."
	$(MAKE) build production=1 dropfirst=1 catalog=carto

	rm -rf $(DIST_DIR)
	mkdir -p $(DIST_DIR)/$(PACKAGE_NAME)
	cp $(BUILD_DIR)/modules.sql $(DIST_DIR)/$(PACKAGE_NAME)/

	$(MAKE) extra-package

	cd $(DIST_DIR) && zip -r $(PACKAGE_NAME).zip . && cd ..

	echo '{"latest_version": "$(PACKAGE_VERSION)"}' > $(DIST_DIR)/metadata.json

extra-package::
