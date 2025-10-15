# Analytics Toolbox Core - Root Makefile
# Creates unified distribution packages (gateway + clouds)

# Default values
# Version is read from clouds/<cloud>/version (clouds defines the version)
OUTPUT_DIR ?= dist
REPO_NAME = core

# Ensure cloud parameter is provided
.PHONY: create-package
create-package:
ifndef cloud
	@echo "Error: cloud parameter required"
	@echo ""
	@echo "Usage: make create-package cloud=<cloud> [options]"
	@echo ""
	@echo "Required:"
	@echo "  cloud=<name>         Cloud platform (redshift, bigquery, snowflake, databricks)"
	@echo ""
	@echo "Optional:"
	@echo "  modules=<modules>    Comma-separated modules to include (default: all)"
	@echo "  functions=<funcs>    Comma-separated functions to include (default: all)"
	@echo "  production=1         Production mode (exclude development/private functions)"
	@echo "  output-dir=<dir>     Output directory (default: dist)"
	@echo ""
	@echo "Note: Version is read from clouds/<cloud>/version"
	@echo ""
	@echo "Examples:"
	@echo "  make create-package cloud=redshift"
	@echo "  make create-package cloud=redshift modules=quadbin"
	@echo "  make create-package cloud=redshift functions=QUADBIN_POLYFILL,QUADBIN_KRING"
	@echo "  make create-package cloud=redshift production=1"
	@exit 1
endif
	@# Read version from clouds/<cloud>/version (clouds defines the version)
	@if [ ! -f "clouds/$(cloud)/version" ]; then \
		echo "Error: clouds/$(cloud)/version file not found"; \
		echo "Version must be defined in clouds/<cloud>/version"; \
		exit 1; \
	fi
	@VERSION=$$(cat clouds/$(cloud)/version); \
	echo "========================================================================"; \
	echo "Creating $(REPO_NAME) unified package for $(cloud)"; \
	echo "========================================================================"; \
	echo "  Version:     $$VERSION"; \
	echo "  Modules:     $(if $(modules),$(modules),all)"; \
	echo "  Functions:   $(if $(functions),$(functions),all)"; \
	echo "  Production:  $(if $(production),yes,no)"; \
	echo "  Output:      $(OUTPUT_DIR)"; \
	echo ""; \
	$(MAKE) --no-print-directory _create-gateway-package VERSION=$$VERSION; \
	$(MAKE) --no-print-directory _add-clouds-sql VERSION=$$VERSION; \
	$(MAKE) --no-print-directory _zip-package VERSION=$$VERSION; \
	echo ""; \
	echo "========================================================================"; \
	echo "✓ Package created successfully"; \
	echo "========================================================================"; \
	echo "  Location: $(OUTPUT_DIR)/carto-at-$(cloud)-$$VERSION.zip"; \
	echo ""; \
	echo "To install:"; \
	echo "  1. Extract: cd $(OUTPUT_DIR) && unzip carto-at-$(cloud)-$$VERSION.zip"; \
	echo "  2. Setup: cd carto-at-$(cloud)-$$VERSION && python3 -m venv .venv && source .venv/bin/activate"; \
	echo "  3. Install dependencies: pip install -r scripts/requirements.txt"; \
	echo "  4. Run installer: python scripts/install.py"; \
	echo ""

# Internal target: Create gateway package
.PHONY: _create-gateway-package
_create-gateway-package:
	@echo "Step 1/3: Creating gateway package (Lambda functions)..."
	@(cd gateway && $(MAKE) create-package \
		cloud=$(cloud) \
		PACKAGE_VERSION=$(VERSION) \
		$(if $(modules),modules=$(modules),) \
		$(if $(functions),functions=$(functions),) \
		$(if $(production),production=$(production),)) || exit 1
	@# Extract gateway package to target location (clean first to avoid prompts)
	@mkdir -p $(OUTPUT_DIR)
	@rm -rf $(OUTPUT_DIR)/carto-at-$(cloud)-$(VERSION)
	@if [ ! -f "gateway/dist/carto-at-$(cloud)-$(VERSION).zip" ]; then \
		echo "Error: Gateway package not found after build"; \
		exit 1; \
	fi
	@(cd gateway/dist && unzip -q carto-at-$(cloud)-$(VERSION).zip -d ../../$(OUTPUT_DIR)) || exit 1
	@echo "  ✓ Gateway package created and extracted"
	@echo ""

# Internal target: Add clouds SQL to package
.PHONY: _add-clouds-sql
_add-clouds-sql:
	@echo "Step 2/3: Adding clouds SQL (native UDFs)..."
	@if [ -d "clouds/$(cloud)/modules" ]; then \
		echo "  Building clouds SQL..."; \
		(cd clouds/$(cloud) && $(MAKE) build-modules \
			$(if $(production),production=1,) \
			$(if $(modules),modules=$(modules),) \
			$(if $(functions),functions=$(functions),)) || exit 1; \
		python3 gateway/scripts/add_clouds_sql.py \
			--package-dir=$(OUTPUT_DIR)/carto-at-$(cloud)-$(VERSION) \
			--cloud=$(cloud) || exit 1; \
		echo "  ✓ Clouds SQL added"; \
	else \
		echo "  ⚠️  No clouds SQL found for $(cloud) (gateway-only package)"; \
	fi
	@echo ""

# Internal target: Create final ZIP
.PHONY: _zip-package
_zip-package:
	@echo "Step 3/3: Creating ZIP archive..."
	@rm -f $(OUTPUT_DIR)/carto-at-$(cloud)-$(VERSION).zip
	@cd $(OUTPUT_DIR) && zip -r carto-at-$(cloud)-$(VERSION).zip carto-at-$(cloud)-$(VERSION) -q
	@echo "  ✓ ZIP created"

# Deploy both gateway and clouds
.PHONY: deploy
deploy:
ifndef cloud
	@echo "Error: cloud parameter required"
	@echo "Usage: make deploy cloud=<cloud> [options]"
	@exit 1
endif
	@echo "========================================================================"
	@echo "Deploying Analytics Toolbox to $(cloud)"
	@echo "========================================================================"
	@echo ""
	@echo "Step 1/2: Deploying gateway (Lambda functions)..."
	@cd gateway && $(MAKE) deploy cloud=$(cloud) \
		$(if $(modules),modules=$(modules),) \
		$(if $(functions),functions=$(functions),) \
		$(if $(production),production=$(production),)
	@echo ""
	@echo "Step 2/2: Deploying clouds (SQL UDFs)..."
	@if [ -d "clouds/$(cloud)" ]; then \
		cd clouds/$(cloud) && $(MAKE) deploy \
			$(if $(modules),modules=$(modules),) \
			$(if $(functions),functions=$(functions),); \
	else \
		echo "  ⚠️  No clouds directory for $(cloud)"; \
	fi
	@echo ""
	@echo "========================================================================"
	@echo "✓ Deployment complete"
	@echo "========================================================================"

# Remove both gateway and clouds deployments
.PHONY: remove
remove:
ifndef cloud
	@echo "Error: cloud parameter required"
	@echo "Usage: make remove cloud=<cloud>"
	@exit 1
endif
	@echo "========================================================================"
	@echo "Removing Analytics Toolbox from $(cloud)"
	@echo "========================================================================"
	@echo ""
	@echo "Step 1/2: Removing clouds (SQL UDFs)..."
	@if [ -d "clouds/$(cloud)" ]; then \
		cd clouds/$(cloud) && $(MAKE) remove; \
	fi
	@echo ""
	@echo "Step 2/2: Removing gateway (Lambda functions)..."
	@cd gateway && $(MAKE) remove cloud=$(cloud) || echo "  ⚠️  Gateway removal (best effort)"
	@echo ""
	@echo "========================================================================"
	@echo "✓ Removal complete"
	@echo "========================================================================"

# Run tests for both gateway and clouds
.PHONY: test
test:
ifndef cloud
	@echo "Error: cloud parameter required"
	@echo "Usage: make test cloud=<cloud>"
	@exit 1
endif
	@echo "========================================================================"
	@echo "Running tests for $(cloud)"
	@echo "========================================================================"
	@echo ""
	@echo "Step 1/2: Testing gateway..."
	@cd gateway && $(MAKE) test-unit cloud=$(cloud) || echo "  ⚠️  Gateway tests (non-blocking)"
	@echo ""
	@echo "Step 2/2: Testing clouds..."
	@if [ -d "clouds/$(cloud)" ]; then \
		cd clouds/$(cloud) && $(MAKE) test; \
	fi
	@echo ""
	@echo "========================================================================"
	@echo "✓ Tests complete"
	@echo "========================================================================"

# Run linting for both gateway and clouds
.PHONY: lint
lint:
ifndef cloud
	@echo "Error: cloud parameter required"
	@echo "Usage: make lint cloud=<cloud>"
	@exit 1
endif
	@echo "========================================================================"
	@echo "Linting $(cloud)"
	@echo "========================================================================"
	@echo ""
	@echo "Step 1/2: Linting gateway..."
	@cd gateway && $(MAKE) lint cloud=$(cloud) || echo "  ⚠️  Gateway lint warnings (non-blocking)"
	@echo ""
	@echo "Step 2/2: Linting clouds..."
	@if [ -d "clouds/$(cloud)" ]; then \
		cd clouds/$(cloud) && $(MAKE) lint; \
	fi
	@echo ""
	@echo "========================================================================"
	@echo "✓ Linting complete"
	@echo "========================================================================"

# Clean build artifacts
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(OUTPUT_DIR)
	@cd gateway && $(MAKE) clean
	@if [ -d "clouds/$(cloud)" ] && [ -n "$(cloud)" ]; then \
		cd clouds/$(cloud) && $(MAKE) clean; \
	fi
	@echo "✓ Clean complete"

# Show help
.PHONY: help
help:
	@echo "Analytics Toolbox Core - Build System"
	@echo ""
	@echo "Main targets (require cloud=<cloud>):"
	@echo "  deploy          Deploy both gateway (Lambda) and clouds (SQL UDFs)"
	@echo "  remove          Remove both gateway and clouds deployments"
	@echo "  test            Run tests for gateway and clouds"
	@echo "  lint            Lint gateway and clouds code"
	@echo ""
	@echo "Package targets:"
	@echo "  create-package  Create unified distribution package (gateway + clouds)"
	@echo ""
	@echo "Utility targets:"
	@echo "  clean           Remove build artifacts"
	@echo "  help            Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make deploy cloud=redshift"
	@echo "  make test cloud=redshift"
	@echo "  make create-package cloud=redshift production=1"
	@echo ""
	@echo "See 'make create-package' for package options"
