# Makefile for Snowflake

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

DIST_DIR ?= $(ROOT_DIR)/dist
BUILD_DIR ?= $(ROOT_DIR)/build
ESLINTRC_DIR ?= $(ROOT_DIR)/../..
COMMON_DIR = $(ROOT_DIR)/common
PACKAGE_VERSION ?= $(shell cat $(ROOT_DIR)/version)
PACKAGE_NAME ?= carto-analytics-toolbox-core-snowflake-$(PACKAGE_VERSION)

include $(COMMON_DIR)/Makefile

.SILENT:

.PHONY: help lint build deploy test remove clean create-package deploy-native-app-package deploy-native-app

help:
	echo "Available targets: lint build deploy test remove clean create-package deploy-native-app-package deploy-native-app"

lint:
	$(MAKE) lint-libraries
	$(MAKE) lint-modules
	$(MAKE) lint-common

lint-libraries:
	$(MAKE) -C libraries/javascript lint

lint-modules:
	$(MAKE) -C modules lint

lint-common: $(NODE_MODULES_DEV) venv3
	echo "Linting common..."
	echo "- Lint JavaScript files"
	PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
	eslint --config $(ESLINTRC_DIR)/.eslintrc.js $(COMMON_DIR)/*.js --fix
	echo "- Lint Markdown files"
	PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
	markdownlint -f '*.md' --ignore node_modules --disable MD013 MD024 MD033 MD036 MD040 MD041 MD051 MD045 --
	echo "- Lint Python files"
	$(VENV3_BIN)/brunette $(COMMON_DIR) --exclude node_modules --line-length=88 --single-quotes --quiet
	$(VENV3_BIN)/flake8 $(COMMON_DIR) --exclude node_modules --max-line-length=88 --enable-extensions Q0 --ignore=D100,D103,D104,E203

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

build-native-app-setup-script:
	rm -rf $(BUILD_DIR)
	$(MAKE) build-libraries
	mkdir -p $(BUILD_DIR)
	$(MAKE) -C modules build SF_SCHEMA=@@SF_SCHEMA@@
	cp modules/build/modules.sql $(BUILD_DIR)
	$(MAKE) -C modules build-native-app-setup-script
	cp modules/build/setup_script.sql $(BUILD_DIR)

deploy:
	$(MAKE) build-libraries
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
	$(MAKE) build production=1 dropfirst=1 database=CARTO

	rm -rf $(DIST_DIR)
	mkdir -p $(DIST_DIR)/$(PACKAGE_NAME)
	cp $(BUILD_DIR)/modules.sql $(DIST_DIR)/$(PACKAGE_NAME)/

	$(MAKE) extra-package

	cd $(DIST_DIR) && zip -r $(PACKAGE_NAME).zip . && cd ..

	echo '{"latest_version": "$(PACKAGE_VERSION)"}' > $(DIST_DIR)/metadata.json

extra-package::

deploy-native-app-package:
	$(MAKE) build-native-app-setup-script
	$(MAKE) -C native_app build
	$(MAKE) -C native_app deploy-app-package

deploy-native-app:
	$(MAKE) -C native_app deploy-app
