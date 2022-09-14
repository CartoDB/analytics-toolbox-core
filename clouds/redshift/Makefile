# Makefile for Redshift

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

DIST_DIR ?= $(ROOT_DIR)/dist
BUILD_DIR ?= $(ROOT_DIR)/build
COMMON_DIR = $(ROOT_DIR)/common
PACKAGE_VERSION ?= $(shell cat $(ROOT_DIR)/version)
PACKAGE_NAME ?= carto-analytics-toolbox-core-redshift-$(PACKAGE_VERSION)

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
	$(MAKE) -C libraries/python lint

lint-modules:
	$(MAKE) -C modules lint

lint-common: $(NODE_MODULES_DEV) venv3
	echo "Linting common..."
	PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
	eslint --config $(ROOT_DIR)/../../.eslintrc.js $(COMMON_DIR)/*.js --fix
	$(VENV3_BIN)/brunette $(COMMON_DIR) --line-length=88 --single-quotes --quiet
	$(VENV3_BIN)/flake8 $(COMMON_DIR) --enable-extensions Q0 --ignore=D100,D103,D104

build:
	rm -rf $(BUILD_DIR)
	$(MAKE) build-libraries
	$(MAKE) build-modules

build-libraries:
	mkdir -p $(BUILD_DIR)/libs
	$(MAKE) -C libraries/python build
	cp libraries/python/build/libraries.sql $(BUILD_DIR)
	cp libraries/python/build/libs/*.zip $(BUILD_DIR)/libs

build-modules:
	mkdir -p $(BUILD_DIR)
	$(MAKE) -C modules build
	cp modules/build/modules.sql $(BUILD_DIR)

deploy:
	$(MAKE) deploy-libraries
	$(MAKE) deploy-modules

deploy-libraries:
	$(MAKE) -C libraries/python deploy

deploy-modules:
	$(MAKE) -C modules deploy

test:
	$(MAKE) test-libraries
	$(MAKE) test-modules

test-libraries:
	$(MAKE) -C libraries/python test

test-modules:
	$(MAKE) -C modules test

remove:
	$(MAKE) remove-libraries
	$(MAKE) remove-modules

remove-libraries:
	$(MAKE) -C libraries/python remove

remove-modules:
	$(MAKE) -C modules remove

clean:
	rm -rf $(DIST_DIR) $(BUILD_DIR)
	$(MAKE) clean-libraries
	$(MAKE) clean-modules

clean-libraries:
	$(MAKE) -C libraries/python clean

clean-modules:
	$(MAKE) -C modules clean

create-package:
	$(MAKE) build production=1 dropfirst=1

	rm -rf $(DIST_DIR)
	mkdir -p $(DIST_DIR)/$(PACKAGE_NAME)
	cp $(BUILD_DIR)/libraries.sql $(DIST_DIR)/$(PACKAGE_NAME)/
	cp $(BUILD_DIR)/modules.sql $(DIST_DIR)/$(PACKAGE_NAME)/

	$(MAKE) extra-package

	echo '{"latest_version": "$(PACKAGE_VERSION)"}' > $(DIST_DIR)/metadata.json

	cd $(DIST_DIR) && zip -r $(PACKAGE_NAME).zip . && cd ..

extra-package::
