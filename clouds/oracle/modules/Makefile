# Makefile modules for Oracle

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

ENV_DIR ?= $(ROOT_DIR)/..
BUILD_DIR ?= $(ROOT_DIR)/build
SQL_DIR ?= $(ROOT_DIR)/sql
COMMON_DIR ?= $(ROOT_DIR)/../common

MODULES_DIRS ?= .
export ORA_VERSION_FUNCTION ?= VERSION_CORE
export ORA_PACKAGE_VERSION ?= $(shell cat $(ROOT_DIR)/../version)

REPLACEMENTS = "ORA_SCHEMA ORA_VERSION_FUNCTION ORA_PACKAGE_VERSION"

include $(COMMON_DIR)/Makefile

.SILENT:

.PHONY: help lint lint-fix build deploy test remove clean

help:
	echo "Available targets: lint lint-fix build deploy test remove clean"

lint: venv3 $(NODE_MODULES_DEV)
	echo "Linting modules..."
	echo "- Lint Python files"
	$(VENV3_BIN)/brunette test --line-length=88 --single-quotes --quiet || true
	$(VENV3_BIN)/flake8 test --max-line-length=88 --enable-extensions Q0 --ignore=D100,D101,D102,D103,D104,D105,D106,D107,W503,E203 || true
	echo "- Lint Markdown files"
	if [ -n "$$(find . -name '*.md' -not -path '*/node_modules/*' -not -path '*/.pytest_cache/*' 2>/dev/null)" ]; then \
		PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
		markdownlint -f '**/*.md' --ignore **/node_modules/** --disable MD013 MD024 MD033 MD036 MD040 MD041 MD051 MD045 -- || true; \
	else \
		echo "  No markdown files to lint"; \
	fi
	echo "- Lint SQL files"
	$(VENV3_BIN)/python $(COMMON_DIR)/sql_lint.py "$(wildcard $(SQL_DIR)/**/*.sql)" $(COMMON_DIR)/.sqlfluff "$(wildcard $(SQL_DIR)/.sqlfluffignore)" || true

lint-fix: venv3 $(NODE_MODULES_DEV)
	echo "Auto-fixing linting issues in modules..."
	echo "- Fix Python formatting"
	$(VENV3_BIN)/brunette test --line-length=88 --single-quotes
	echo "- Fix Markdown files"
	if [ -n "$$(find . -name '*.md' -not -path '*/node_modules/*' -not -path '*/.pytest_cache/*' 2>/dev/null)" ]; then \
		PATH="$(NODE_MODULES_DEV)/.bin/:$(PATH)" \
		markdownlint -f '**/*.md' --ignore **/node_modules/** --disable MD013 MD024 MD033 MD036 MD040 MD041 MD051 MD045 --fix -- || true; \
	else \
		echo "  No markdown files to fix"; \
	fi
	echo "- Check remaining issues"
	$(VENV3_BIN)/flake8 test --max-line-length=88 --enable-extensions Q0 --ignore=D100,D101,D102,D103,D104,D105,D106,D107,W503,E203
	echo "✓ Auto-fix complete. Review remaining flake8 issues above."

build: $(NODE_MODULES_DEV)
	echo "Building Oracle modules..."
	rm -rf $(BUILD_DIR)
	mkdir $(BUILD_DIR)
	REPLACEMENTS=$(REPLACEMENTS)" "$(REPLACEMENTS_EXTRA) \
	$(COMMON_DIR)/build_modules.js $(MODULES_DIRS) --output=$(BUILD_DIR) \
		--diff="$(diff)" --modules=$(modules) --functions=$(functions) --dropfirst=$(dropfirst)

deploy: check venv3 build
	echo "Deploying Oracle modules..."
	$(VENV3_BIN)/python $(COMMON_DIR)/run_script.py $(BUILD_DIR)/modules.sql
	$(MAKE) extra-deploy

extra-deploy::

test: check venv3 $(NODE_MODULES_DEV)
	echo "Testing Oracle modules..."
	if [ ! -z "`$(COMMON_DIR)/list_functions.js --diff="$(diff)" --modules=$(modules) --functions=$(functions)`" ]; then \
		$(VENV3_BIN)/pytest -rP -p no:warnings -x -vv `$(COMMON_DIR)/list_functions.js --diff="$(diff)" --modules=$(modules) --functions=$(functions)`; \
	fi;

remove: venv3
	echo "Removing Oracle modules..."
ifdef drop-schema
	echo "Dropping schema $(ORA_SCHEMA) with CASCADE..."
	$(VENV3_BIN)/python $(COMMON_DIR)/drop_schema.py
else
	echo "Dropping Analytics Toolbox functions only..."
	REPLACEMENTS=$(REPLACEMENTS)" "$(REPLACEMENTS_EXTRA) \
	$(VENV3_BIN)/python $(COMMON_DIR)/run_script.py $(COMMON_DIR)/INTERNAL_DROP_FUNCTIONS.sql
endif

clean:
	echo "Cleaning Oracle modules..."
	rm -rf $(BUILD_DIR) $(VENV3_DIR) $(NODE_MODULES_DEV)
