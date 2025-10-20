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
# Version is read from clouds/<cloud>/version in the core repository
# ROOT_DIR is gateway/, so ../clouds/<cloud>/version is core/clouds/<cloud>/version
PACKAGE_VERSION ?= $(shell cat $(ROOT_DIR)/../clouds/$(cloud)/version 2>/dev/null || echo "dev")
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

.PHONY: help lint test test-unit test-integration list validate build deploy deploy-lambdas deploy-functions remove clean create-package update-dev-requirements

help:
	echo "Available targets:"
	echo "  help                    - Show this help message"
	echo "  lint                    - Run code quality checks"
	echo "  lint-fix                - Auto-fix code formatting issues"
	echo "  build                   - Build functions with shared libraries (required for testing)"
	echo "  test                    - Run all tests (unit + integration)"
	echo "  test-unit               - Run unit tests only"
	echo "  test-integration        - Run integration tests only"
	echo "  list                    - List available functions"
	echo "  validate                - Validate function definitions"
	echo "  deploy                  - Deploy functions to cloud (Lambdas + external functions)"
	echo "  deploy-lambdas          - Deploy only Lambda functions"
	echo "  deploy-functions        - Deploy only external functions (Lambdas must exist)"
	echo "  remove                  - Remove deployed functions"
	echo "  create-package          - Create distribution package"
	echo "  update-dev-requirements - Regenerate requirements-dev.txt from functions"
	echo "  clean                   - Clean build artifacts and cache"
	echo "  clean-all               - Clean everything including venv"

venv:
	@if [ ! -d "$(VENV_DIR)" ]; then \
		echo "Creating venv with: $$(python3 --version 2>&1)"; \
		python3 -m venv $(VENV_DIR) || exit 1; \
		rm -rf $(VENV_DIR)/lib/**/site-packages/~*; \
		$(VENV_BIN)/pip install --upgrade pip || exit 1; \
		echo "Installing dependencies from $(ROOT_DIR)/requirements.txt"; \
		$(VENV_BIN)/pip install -r $(ROOT_DIR)/requirements.txt || exit 1; \
		echo "✓ Venv created successfully"; \
	fi

install-dev: venv
	@if ! $(VENV_BIN)/python -c "import black" 2>/dev/null; then \
		$(VENV_BIN)/pip install -r $(ROOT_DIR)/requirements-dev.txt -q; \
	fi

lint: install-dev
	echo "Linting..."
	$(VENV_BIN)/black $(LINT_PATHS) --check --line-length=88
	$(VENV_BIN)/flake8 $(LINT_PATHS) \
		--max-line-length=88 \
		--extend-ignore=E203,W503,Q000

lint-fix: install-dev
	$(VENV_BIN)/black $(LINT_PATHS) --line-length=88

list: venv
	echo "Listing functions for $(cloud)..."
	cd $(LOGIC_ROOT)/clouds/$(cloud) && $(VENV_BIN)/python cli.py list-functions \
		$(if $(modules),--modules=$(modules),) \
		$(if $(functions),--functions=$(functions),) \
		$(EXTRA_CLI_ARGS)

validate: venv
	echo "Validating functions..."
	cd $(LOGIC_ROOT)/clouds/$(cloud) && $(VENV_BIN)/python cli.py validate \
		$(VALIDATE_EXTRA_ARGS)

build: venv
	echo "Building functions with shared libraries..."
	$(VENV_BIN)/python $(ROOT_DIR)/tools/build_functions.py --cloud $(cloud)

test-unit: install-dev build
	echo "Running unit tests..."
	@if [ -n "$(modules)" ]; then \
		MODULE_PATHS=$$(echo "$(modules)" | tr ',' '\n' | sed 's|^|$(FUNCTIONS_ROOT)/|' | sed 's|$$|/|' | tr '\n' ' '); \
		$(VENV_BIN)/python -m pytest $$MODULE_PATHS -m "not integration" || [ $$? -eq 5 ]; \
	elif [ -n "$(functions)" ]; then \
		FUNC_PATHS=$$(for func in $$(echo "$(functions)" | tr ',' ' '); do \
			find $(FUNCTIONS_ROOT) -type d -name "$$func" -path "*/functions/*/$$func"; \
		done | tr '\n' ' '); \
		$(VENV_BIN)/python -m pytest $$FUNC_PATHS -m "not integration" || [ $$? -eq 5 ]; \
	else \
		$(VENV_BIN)/python -m pytest $(TEST_PATHS) -m "not integration" || [ $$? -eq 5 ]; \
	fi

test-integration: install-dev build
	echo "Running integration tests..."
	@if [ -n "$(modules)" ]; then \
		MODULE_PATHS=$$(echo "$(modules)" | tr ',' '\n' | sed 's|^|$(FUNCTIONS_ROOT)/|' | sed 's|$$|/|' | tr '\n' ' '); \
		$(VENV_BIN)/python -m pytest $$MODULE_PATHS -m integration || [ $$? -eq 5 ]; \
	elif [ -n "$(functions)" ]; then \
		FUNC_PATHS=$$(for func in $$(echo "$(functions)" | tr ',' ' '); do \
			find $(FUNCTIONS_ROOT) -type d -name "$$func" -path "*/functions/*/$$func"; \
		done | tr '\n' ' '); \
		$(VENV_BIN)/python -m pytest $$FUNC_PATHS -m integration || [ $$? -eq 5 ]; \
	else \
		$(VENV_BIN)/python -m pytest $(TEST_PATHS) -m integration || [ $$? -eq 5 ]; \
	fi

test: test-unit test-integration
	echo "✓ All tests passed"

deploy: venv
	echo "Deploying to $(cloud)..."
	cd $(LOGIC_ROOT)/clouds/$(cloud) && $(VENV_BIN)/python cli.py deploy-all \
		$(if $(modules),--modules=$(modules),) \
		$(if $(functions),--functions=$(functions),) \
		$(if $(production),--production,) \
		$(if $(diff),--diff,) \
		$(if $(dry-run),--dry-run,) \
		$(EXTRA_CLI_ARGS)

deploy-lambdas: venv
	echo "Deploying Lambda functions only to $(cloud)..."
	cd $(LOGIC_ROOT)/clouds/$(cloud) && $(VENV_BIN)/python cli.py deploy-lambdas \
		$(if $(modules),--modules=$(modules),) \
		$(if $(functions),--functions=$(functions),) \
		$(if $(diff),--diff,) \
		$(if $(dry-run),--dry-run,) \
		$(EXTRA_CLI_ARGS)

deploy-functions: venv
	echo "Deploying external functions only to $(cloud)..."
	cd $(LOGIC_ROOT)/clouds/$(cloud) && $(VENV_BIN)/python cli.py deploy-functions \
		$(if $(modules),--modules=$(modules),) \
		$(if $(functions),--functions=$(functions),) \
		$(if $(production),--production,) \
		$(if $(dry-run),--dry-run,) \
		$(EXTRA_CLI_ARGS)

remove: venv
	echo "Removing deployment..."
	cd $(LOGIC_ROOT)/clouds/$(cloud) && $(VENV_BIN)/python cli.py remove-all \
		$(if $(modules),--modules=$(modules),) \
		$(if $(functions),--functions=$(functions),) \
		$(if $(production),--production,) \
		$(if $(drop-schema),--drop-schema,) \
		$(if $(dry-run),--dry-run,) \
		$(EXTRA_CLI_ARGS)

create-package: venv
	echo "Creating distribution package..."
	rm -rf $(DIST_DIR)
	mkdir -p $(DIST_DIR)
	cd $(LOGIC_ROOT)/clouds/$(cloud) && $(VENV_BIN)/python cli.py create-package \
		$(DIST_DIR) \
		--version $(PACKAGE_VERSION) \
		$(if $(functions),--functions=$(functions),) \
		$(if $(production),--production,) \
		$(EXTRA_CLI_ARGS)
	echo ""
	echo "========================================================================"
	echo "✓ Package created successfully"
	echo "========================================================================"
	echo "  Location: $(DIST_DIR)/carto-at-$(cloud)-$(PACKAGE_VERSION).zip"
	echo ""
	echo "To install:"
	echo "  1. Extract: cd $(DIST_DIR) && unzip carto-at-$(cloud)-$(PACKAGE_VERSION).zip"
	echo "  2. Setup: cd carto-at-$(cloud)-$(PACKAGE_VERSION) && python3 -m venv .venv && source .venv/bin/activate"
	echo "  3. Install dependencies: pip install -r scripts/requirements.txt"
	echo "  4. Run installer: python scripts/install.py"
	echo ""

clean:
	echo "Cleaning..."
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
	rm -rf $(DIST_DIR) $(BUILD_DIR) $(VENV_DIR)

clean-all: clean

# Dependency management tools
update-dev-requirements: venv
	echo "Regenerating requirements-dev.txt from function requirements..."
	$(VENV_BIN)/python $(ROOT_DIR)/tools/generate_dev_requirements.py $(if $(cloud),--cloud $(cloud),)
	echo ""
	echo "✓ Updated requirements-dev.txt"
	echo "  Review changes and run: make install-dev"
