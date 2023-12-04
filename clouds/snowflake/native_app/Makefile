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
APP_VERSION ?= $(shell cat $(ROOT_DIR)/../version)
APP_MAJOR_VERSION = v$(firstword $(subst ., ,$(APP_VERSION)))
APP_FORMATTED_VERSION = v$(subst .,_,$(APP_VERSION))

APP_STAGE_NAME ?= $(SF_SCHEMA).APP_$(SF_UNQUALIFIED_SCHEMA)
ifeq ($(production),1)
	APP_STAGE_LOCATION ?= $(APP_STAGE_NAME)/$(APP_FORMATTED_VERSION)
else
	APP_STAGE_LOCATION ?= $(APP_STAGE_NAME)
endif

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
	$(COMMON_DIR)/run-query.js "CREATE STAGE IF NOT EXISTS $(APP_STAGE_NAME);"
	$(COMMON_DIR)/run-query.js "PUT file://$(DIST_DIR)/$(APP_PACKAGE_DIST_NAME)/* @$(APP_STAGE_LOCATION) overwrite=true auto_compress=false;"

ifeq ($(create_package),1)
	echo "Creating native app package..."
	$(COMMON_DIR)/run-query.js "DROP APPLICATION PACKAGE IF EXISTS $(APP_PACKAGE_NAME);"
	$(COMMON_DIR)/run-query.js "CREATE APPLICATION PACKAGE $(APP_PACKAGE_NAME);"
endif

ifeq ($(or $(create_package),$(deploy_version)),1)
	echo "Deploying native app package version..."
	$(COMMON_DIR)/run-query.js "ALTER APPLICATION PACKAGE $(APP_PACKAGE_NAME) \
		ADD VERSION $(APP_MAJOR_VERSION) \
		USING @$(APP_STAGE_LOCATION);"
else
	echo "Deploying native app package patch..."
	$(COMMON_DIR)/run-query.js "ALTER APPLICATION PACKAGE $(APP_PACKAGE_NAME) \
		ADD PATCH FOR VERSION $(APP_MAJOR_VERSION) \
		USING @$(APP_STAGE_LOCATION);"
endif
	echo "Setting release package to the newest patch"
	SET_PACKAGE_RELEASE=1 \
	APP_PACKAGE_NAME=$(APP_PACKAGE_NAME) \
	VERSION=$(APP_MAJOR_VERSION) \
	$(COMMON_DIR)/native-app-setup.js

ifeq ($(deploy_version),1)
	echo "Requesting previous native app package version drop..."
# This ensures that there are no more than 2 versions which is a Snowflake limitations
	DROP_PREVIOUS_VERSION=1 \
	APP_PACKAGE_NAME=$(APP_PACKAGE_NAME) \
	VERSION=$(APP_MAJOR_VERSION) \
	$(COMMON_DIR)/native-app-setup.js
endif

deploy-app:
	echo "Installing native app... (this may take a while)"
	$(COMMON_DIR)/run-query.js "DROP APPLICATION IF EXISTS $(APP_NAME);"
	$(COMMON_DIR)/run-query.js "CREATE APPLICATION $(APP_NAME) \
		FROM APPLICATION PACKAGE $(APP_PACKAGE_NAME);"
	$(MAKE) extra-deploy

extra-deploy::

upgrade-app:
	echo "Upgrading native app... (this may take a while)"
	$(COMMON_DIR)/run-query.js "ALTER APPLICATION $(APP_NAME) UPGRADE;"