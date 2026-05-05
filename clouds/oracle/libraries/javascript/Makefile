# Makefile for Oracle JavaScript libraries (MLE-JS modules)

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

LIBS_DIR ?= $(ROOT_DIR)/libs
SRC_DIR ?= $(ROOT_DIR)/src
TEST_DIR ?= $(ROOT_DIR)/test
BUILD_DIR ?= $(ROOT_DIR)/build
ESLINTRC_DIR ?= $(ROOT_DIR)/../../../..
COMMON_DIR = $(ROOT_DIR)/../../common

include $(COMMON_DIR)/Makefile

.SILENT:

.PHONY: help lint lint-fix build clean

help:
	echo "Available targets: lint lint-fix build clean"

lint: $(NODE_MODULES_DEV)
	echo "Linting libraries..."
	echo "- Lint JavaScript files"
	PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
	eslint --config $(ESLINTRC_DIR)/.eslintrc.js $(LIBS_DIR) $(SRC_DIR) $(TEST_DIR)

lint-fix: $(NODE_MODULES_DEV)
	echo "Auto-fixing lint issues in libraries..."
	echo "- Fix JavaScript files"
	PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
	eslint --config $(ESLINTRC_DIR)/.eslintrc.js $(LIBS_DIR) $(SRC_DIR) $(TEST_DIR) --fix

# Build all JS libraries: one rollup invocation per *.js file in libs/.
# Output goes to build/<name>.js for substitution into _module.sql via
# the @@ORA_LIBRARY_<NAME>@@ placeholder.
build: $(NODE_MODULES_DEV)
	echo "Building MLE-JS libraries..."
	rm -rf $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)
	yarn -s --cwd $(ROOT_DIR) install
	for f in `ls $(LIBS_DIR)/*.js | xargs -n1 basename`; do \
		echo "- Bundling $$f"; \
		PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
		DIRS=$(LIBS_DIR) \
		FILENAME=$$f \
		OUTPUT=$(BUILD_DIR)/$$f \
		rollup --config $(COMMON_DIR)/rollup.config.js; \
	done

clean:
	echo "Cleaning JS libraries..."
	rm -rf $(BUILD_DIR) $(ROOT_DIR)/node_modules
