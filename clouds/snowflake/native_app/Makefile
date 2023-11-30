# Makefile native app for Snowflake

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

DIST_DIR ?= $(ROOT_DIR)/../dist
ENV_DIR ?= $(ROOT_DIR)/..
BUILD_DIR ?= $(ROOT_DIR)/../build
COMMON_DIR = $(ROOT_DIR)/../common
APP_DIR ?= $(ROOT_DIR)

include $(COMMON_DIR)/Makefile

APP_NAME ?= APP_$(SF_UNQUALIFIED_SCHEMA)
APP_PACKAGE_NAME ?= APP_PACKAGE_$(SF_UNQUALIFIED_SCHEMA)
APP_PACKAGE_DIST_NAME ?= carto-analytics-toolbox-core-snowflake-native-app-$(APP_VERSION)
APP_STAGE_NAME ?= $(SF_SCHEMA).APP_$(SF_UNQUALIFIED_SCHEMA)
APP_VERSION ?= $(shell cat $(ROOT_DIR)/../version)
APP_FORMATTED_VERSION = v_$(subst .,_,$(APP_VERSION))


.SILENT:

.PHONY: help build deploy

help:
	echo "Available targets: help build deploy"

build:
	rm -rf $(DIST_DIR)
	mkdir -p $(DIST_DIR)/$(APP_PACKAGE_DIST_NAME)
	cp $(BUILD_DIR)/setup_script.sql $(DIST_DIR)/$(APP_PACKAGE_DIST_NAME)/
	sed 's/@@VERSION@@/$(APP_VERSION)/g' $(APP_DIR)/manifest.yml > $(DIST_DIR)/$(APP_PACKAGE_DIST_NAME)/manifest.yml
	cp $(APP_DIR)/README.md $(DIST_DIR)/$(APP_PACKAGE_DIST_NAME)/


deploy-app-package:
	echo "Deploying native app package..."
	$(COMMON_DIR)/run-query.js "CREATE STAGE IF NOT EXISTS $(APP_STAGE_NAME);"
ifeq ($(production),1)
	$(COMMON_DIR)/run-query.js "PUT file://$(DIST_DIR)/$(APP_PACKAGE_DIST_NAME)/* @$(APP_STAGE_NAME)/$(APP_FORMATTED_VERSION) overwrite=true auto_compress=false;"
else
	$(COMMON_DIR)/run-query.js "PUT file://$(DIST_DIR)/$(APP_PACKAGE_DIST_NAME)/* @$(APP_STAGE_NAME) overwrite=true auto_compress=false;"
endif

# IF DROP FIRST
	$(COMMON_DIR)/run-query.js "DROP APPLICATION PACKAGE IF EXISTS $(APP_PACKAGE_NAME);"
	$(COMMON_DIR)/run-query.js "CREATE APPLICATION PACKAGE $(APP_PACKAGE_NAME);"
ifeq ($(production),1)
	$(COMMON_DIR)/run-query.js "ALTER APPLICATION PACKAGE $(APP_PACKAGE_NAME) \
		ADD VERSION $(APP_FORMATTED_VERSION) \
		USING @$(APP_STAGE_NAME)/$(APP_FORMATTED_VERSION);"
else
	$(COMMON_DIR)/run-query.js "ALTER APPLICATION PACKAGE $(APP_PACKAGE_NAME) \
		ADD VERSION $(APP_FORMATTED_VERSION) \
		USING @$(APP_STAGE_NAME);"
endif

deploy-app:
	echo "Installing native app... (this may take a while)"
	$(COMMON_DIR)/run-query.js "DROP APPLICATION IF EXISTS $(APP_NAME);"
	$(COMMON_DIR)/run-query.js "CREATE APPLICATION $(APP_NAME) \
		FROM APPLICATION PACKAGE $(APP_PACKAGE_NAME) \
		USING VERSION $(APP_FORMATTED_VERSION);"
	$(MAKE) extra-deploy

extra-deploy::

deploy:
	$(MAKE) deploy-app-package
	$(MAKE) deploy-app