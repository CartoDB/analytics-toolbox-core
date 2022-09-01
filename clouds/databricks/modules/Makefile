# Makefile modules for Redshift

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

ENV_DIR ?= $(ROOT_DIR)/..
BUILD_DIR ?= $(ROOT_DIR)/build
COMMON_DIR ?= $(ROOT_DIR)/../common

MODULES_DIRS ?= .
export RS_VERSION_FUNCTION ?= VERSION_CORE
ifeq ($(production),1)
export RS_PACKAGE_VERSION ?= $(shell cat $(ROOT_DIR)/../version)
else
export RS_PACKAGE_VERSION ?= $(shell cat $(ROOT_DIR)/../version)-dev
endif

REPLACEMENTS = "RS_SCHEMA RS_LIBRARY RS_VERSION_FUNCTION RS_PACKAGE_VERSION"

include $(COMMON_DIR)/Makefile

.SILENT:

.PHONY: help lint build deploy test remove clean

help:
	echo "Available targets: lint build deploy test remove clean"

test-integration: check check-extra venv
	. $(COMMON_DIR)/venv/bin/activate && \
	for module in `ls $(CLOUD_DIR)/modules`; do \
		echo "> Module $${module}"; \
		pytest -rP -p no:warnings modules/$${module} || exit 1; \
	done; \
	deactivate
	
test-integration-full:
	$(MAKE) deploy
	$(MAKE) test-integration || ($(MAKE) clean-deploy && exit 1)
	$(MAKE) clean-deploy

