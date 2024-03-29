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

lint-common: venv3 $(NODE_MODULES_DEV)
	echo "Linting common..."
	echo "- Lint JavaScript files"
	PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
	eslint --config $(ROOT_DIR)/../../.eslintrc.js $(COMMON_DIR)/*.js --fix
	echo "- Lint Markdown files"
	PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
	markdownlint -f '*.md' --ignore node_modules --disable MD013 MD024 MD033 MD036 MD040 MD041 MD051 MD045 --
	echo "- Lint Python files"
	$(VENV3_BIN)/brunette $(COMMON_DIR) --exclude node_modules --line-length=88 --single-quotes --quiet
	$(VENV3_BIN)/flake8 $(COMMON_DIR) --exclude node_modules --max-line-length=88 --enable-extensions Q0 --ignore=D100,D103,D104,E203,W503

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
	$(MAKE) build production=1 dropfirst=1 libsurl=1

	rm -rf $(DIST_DIR)
	mkdir -p $(DIST_DIR)/$(PACKAGE_NAME)
	cp $(BUILD_DIR)/libraries.sql $(DIST_DIR)/$(PACKAGE_NAME)/
	cp $(BUILD_DIR)/modules.sql $(DIST_DIR)/$(PACKAGE_NAME)/

	$(MAKE) extra-package

	cd $(DIST_DIR) && zip -r $(PACKAGE_NAME).zip . && cd ..

	echo '{"latest_version": "$(PACKAGE_VERSION)"}' > $(DIST_DIR)/metadata.json

extra-package::
