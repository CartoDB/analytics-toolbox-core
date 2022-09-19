# Makefile for Databricks

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

COMMON_DIR = $(ROOT_DIR)/common

include $(COMMON_DIR)/Makefile

.SILENT:

.PHONY: help lint build deploy test remove clean

help:
	echo "Please choose one of the following targets: lint build deploy test remove clean"

lint:
	$(MAKE) lint-libraries
	$(MAKE) lint-modules
	$(MAKE) lint-common

lint-libraries:
	$(MAKE) -C libraries/scala lint

lint-modules:
	$(MAKE) -C modules lint

lint-common: $(NODE_MODULES_DEV)
	PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
	markdownlint -f '*.md' --ignore **/node_modules/** --disable MD013 MD024 MD033 MD036 MD040 MD041 MD051 --

build:
	$(MAKE) build-libraries
	$(MAKE) build-modules

build-libraries:
	$(MAKE) -C libraries/scala build

build-modules:
	echo "No action"

deploy:
	$(MAKE) deploy-libraries
	$(MAKE) deploy-modules

deploy-libraries:
	$(MAKE) -C libraries/scala deploy

deploy-modules:
	echo "No action"

test:
	$(MAKE) test-modules
	$(MAKE) test-libraries

test-libraries:
	$(MAKE) -C libraries/scala test

test-modules:
	$(MAKE) -C modules test

remove:
	$(MAKE) remove-libraries
	$(MAKE) remove-modules

remove-libraries:
	$(MAKE) -C libraries/scala remove

remove-modules:
	$(MAKE) -C modules remove

clean:
	$(MAKE) clean-libraries

clean-libraries:
	$(MAKE) -C libraries/scala clean

clean-modules:
	echo "No action"
