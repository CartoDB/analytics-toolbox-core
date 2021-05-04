TESTER ?= ./node_modules/mocha/bin/mocha

NPM ?= npm

# Nothing by default
all:

node_modules: package.json
	$(NPM) i

BQ_PROJECTID ?= cartodb-gcp-backend-data-team
check_environment:
ifndef BQ_DATASET_PROCESSING
	$(error BQ_DATASET_PROCESSING is undefined)
endif

.PHONY: clean
clean:
	rm -rf node_modules

.PHONY: check_integration
check-integration: node_modules check_environment
	$(TESTER) -p -j $(shell find . -maxdepth 1 -name "*_integration.js" | wc -l) -t 240000 $(shell find . -maxdepth 1 -name "*_integration.js")
	$(MAKE) check_integration_standalone

# These tests need to be executed one by one because they modify the environment
.PHONY: check_integration_standalone
check-integration-standalone: node_modules check_environment
	$(TESTER) -t 240000 $(shell find . -maxdepth 1 -name "*_integration_standalone.js")