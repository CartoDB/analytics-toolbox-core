ESLINT ?= ../node_modules/eslint/bin/eslint.js
NPM ?= npm

# Nothing by default
all:

node_modules: package.json
	${NPM} ci

.PHONY: check
check: node_modules
	$(NPM) test *_test.js

.PHONY: clean
clean:
	rm -rf node_modules