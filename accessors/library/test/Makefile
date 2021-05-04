TESTER ?= ./node_modules/mocha/bin/mocha

NPM ?= npm

# Nothing by default
all:

node_modules: package.json
	$(NPM) i

.PHONY: check
check: node_modules
	$(TESTER) -p -j 4 -t 10000 $(shell find . -maxdepth 1 -name "*_test.js")

.PHONY: clean
clean:
	rm -rf node_modules