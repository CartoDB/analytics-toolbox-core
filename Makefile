# Global Makefile for Analytics Toolbox Core
# Allows running commands like: make lint cloud=databricks

.PHONY: help lint build deploy test remove clean create-package

# Supported clouds
VALID_CLOUDS := databricks

# Check if cloud parameter is provided (except for help target)
ifndef cloud
ifneq ($(MAKECMDGOALS),help)
ifneq ($(MAKECMDGOALS),)
$(error cloud parameter is required. Usage: make <target> cloud=<databricks>)
endif
endif
endif

# Validate cloud parameter (only if cloud is set)
ifdef cloud
ifeq ($(filter $(cloud),$(VALID_CLOUDS)),)
$(error Invalid cloud '$(cloud)'. Valid options: $(VALID_CLOUDS))
endif

# Cloud directory
CLOUD_DIR := clouds/$(cloud)

# Check if cloud directory exists
ifeq ($(wildcard $(CLOUD_DIR)/Makefile),)
$(error Cloud '$(cloud)' does not have a Makefile at $(CLOUD_DIR)/Makefile)
endif
endif

# Capture all command-line variables except 'cloud'
# This creates a string of VAR=value pairs to forward to the cloud Makefile
FORWARD_VARS := $(foreach v,$(filter-out cloud,$(.VARIABLES)),$(if $(filter command line,$(origin $(v))),$(v)=$($(v)),))

# Default target
help:
	@echo "Global Makefile for Analytics Toolbox Core"
	@echo ""
	@echo "Usage: make <target> cloud=<cloud> [parameters]"
	@echo ""
	@echo "Available clouds: $(VALID_CLOUDS)"
	@echo ""
	@echo "Common targets:"
	@echo "  help          Show this help message"
	@echo "  lint          Run linting"
	@echo "  build         Build modules"
	@echo "  deploy        Deploy modules"
	@echo "  test          Run tests"
	@echo "  remove        Remove deployed resources"
	@echo "  clean         Clean build artifacts"
	@echo "  create-package Create distribution package"
	@echo ""
	@echo "Examples:"
	@echo "  make lint cloud=databricks"
	@echo "  make deploy cloud=databricks functions=XXX"
	@echo "  make test cloud=databricks modules=yyy"
	@echo "  make build cloud=databricks production=1"
	@echo ""
	@echo "For cloud-specific help:"
	@echo "  cd clouds/<cloud> && make help"

# Forward all targets to the cloud-specific Makefile
lint build deploy test remove clean create-package:
ifndef cloud
	@echo "Error: cloud parameter is required for target '$@'"
	@echo "Usage: make $@ cloud=<databricks>"
	@exit 1
else
	@echo "Running '$@' for cloud '$(cloud)'..."
	@cd $(CLOUD_DIR) && $(MAKE) --no-print-directory $@ $(FORWARD_VARS)
endif
