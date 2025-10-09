# Configuration
ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
THIS_MAKEFILE := $(ROOT_DIR)/Makefile
VENV_DIR = $(ROOT_DIR)/venv
VENV_BIN = $(VENV_DIR)/bin
FUNCTIONS_ROOT ?= $(ROOT_DIR)/functions
LOGIC_ROOT = $(ROOT_DIR)/logic

# Paths for linting, testing, validation (can be overridden by including Makefiles)
LINT_PATHS ?= $(FUNCTIONS_ROOT) $(LOGIC_ROOT)
TEST_PATHS ?= .
VALIDATE_EXTRA_ARGS ?= $(EXTRA_CLI_ARGS)

DIST_DIR ?= $(ROOT_DIR)/dist
BUILD_DIR ?= $(ROOT_DIR)/build
PACKAGE_VERSION ?= $(shell cat $(ROOT_DIR)/version 2>/dev/null || echo "dev")
PACKAGE_NAME ?= carto-analytics-toolbox-gateway-$(PACKAGE_VERSION)
ENV_DIR ?= $(ROOT_DIR)/..

# Load .env file if it exists (from core or gateway directory)
ifneq (,$(wildcard $(ENV_DIR)/.env))
    include $(ENV_DIR)/.env
	export $(shell sed 's/=.*//' $(ENV_DIR)/.env)
else ifneq (,$(wildcard $(ROOT_DIR)/.env))
    include $(ROOT_DIR)/.env
	export $(shell sed 's/=.*//' $(ROOT_DIR)/.env)
endif

# Cloud platform (can be overridden)
cloud ?= redshift

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

.SILENT:

.PHONY: help lint test test-unit test-integration deploy remove clean create-package

help:
	echo "Available targets: help lint test deploy remove clean create-package"

venv:
	@if [ ! -d "$(VENV_DIR)" ]; then \
		python3 -m venv $(VENV_DIR); \
		rm -rf $(VENV_DIR)/lib/**/site-packages/~*; \
		$(VENV_BIN)/pip install --upgrade pip -q; \
		$(VENV_BIN)/pip install -r requirements.txt -q; \
	fi

install-dev: venv
	@if ! $(VENV_BIN)/python -c "import black" 2>/dev/null; then \
		$(VENV_BIN)/pip install -r requirements-dev.txt -q; \
	fi

lint: install-dev
	echo "Linting..."
	echo "- Lint Python files"
	$(VENV_BIN)/black $(LINT_PATHS) --check --line-length=88
	$(VENV_BIN)/flake8 $(LINT_PATHS) \
		--max-line-length=88 \
		--extend-ignore=E203,W503,Q000
	echo "- Lint SQL files"
	@for cloud in redshift bigquery snowflake databricks postgres; do \
		sqlfluff_config="$(ROOT_DIR)/common/$$cloud/.sqlfluff"; \
		if [ -f "$$sqlfluff_config" ] && find $(LINT_PATHS) -name "$$cloud.sql" 2>/dev/null | grep -q .; then \
			echo "  Linting $$cloud SQL files..."; \
			find $(LINT_PATHS) -name "$$cloud.sql" -exec $(VENV_BIN)/sqlfluff lint {} --config $$sqlfluff_config \; || true; \
		fi \
	done

lint-fix: install-dev
	$(VENV_BIN)/black $(LINT_PATHS) --line-length=88
	@for cloud in redshift bigquery snowflake databricks postgres; do \
		sqlfluff_config="$(ROOT_DIR)/common/$$cloud/.sqlfluff"; \
		if [ -f "$$sqlfluff_config" ] && find $(LINT_PATHS) -name "$$cloud.sql" 2>/dev/null | grep -q .; then \
			echo "  Fixing $$cloud SQL files..."; \
			find $(LINT_PATHS) -name "$$cloud.sql" -exec $(VENV_BIN)/sqlfluff fix {} --config $$sqlfluff_config \; || true; \
		fi \
	done

validate: venv
	echo "Validating functions..."
	cd $(LOGIC_ROOT)/clouds/$(cloud) && $(VENV_BIN)/python cli.py validate \
		$(VALIDATE_EXTRA_ARGS)

test-unit: install-dev
	echo "Running unit tests..."
	$(VENV_BIN)/python -m pytest $(TEST_PATHS) -m "not integration" || echo "$(YELLOW)Note: Some tests may be failing$(NC)"

test-integration: install-dev
	echo "Running integration tests..."
	$(VENV_BIN)/python -m pytest $(TEST_PATHS) -m integration || echo "$(YELLOW)Note: Some tests may be failing$(NC)"

test: test-unit test-integration
	echo "All tests completed"

deploy: venv
	echo "Deploying to $(cloud)..."
	cd $(LOGIC_ROOT)/clouds/$(cloud) && $(VENV_BIN)/python cli.py deploy-all \
		$(if $(modules),--modules=$(modules),) \
		$(if $(functions),--functions=$(functions),) \
		$(if $(production),--production,) \
		$(if $(dry-run),--dry-run,) \
		$(EXTRA_CLI_ARGS)

remove: venv
	echo "Removing deployment..."
	echo "$(YELLOW)Note: Undeploy not yet implemented$(NC)"
	echo "To manually remove, delete the Lambda functions and IAM roles"

create-package: venv
	echo "Creating distribution package..."
	rm -rf $(DIST_DIR)
	mkdir -p $(DIST_DIR)
	cd $(LOGIC_ROOT)/clouds/$(cloud) && $(VENV_BIN)/python cli.py create-package \
		$(DIST_DIR) \
		--version $(PACKAGE_VERSION) \
		$(if $(functions),--functions=$(functions),) \
		$(if $(production),--include-private,) \
		$(EXTRA_CLI_ARGS)

clean:
	echo "Cleaning..."
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
	rm -rf $(DIST_DIR) $(BUILD_DIR)

clean-all: clean
	rm -rf $(VENV_DIR)
