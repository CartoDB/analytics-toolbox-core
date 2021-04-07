TARGET = ../quadkey_library.js

ESLINT ?= ./node_modules/eslint/bin/eslint.js
NPM ?= npm
BROWSERIFY ?= ./node_modules/.bin/browserify

all: ${TARGET}

JS_FILES = \
	js/quadkey_version.js \
	js/quadint.js

.PHONY: check
check: ${TARGET}
	$(MAKE) -C test/ $@

.PHONY: clean
clean:
	rm -rf ${TARGET} node_modules/
	$(MAKE) -C test/ $@

.PHONY: clang-format check-clang-format eslint check-eslint
node_modules: package.json
	$(NPM) ci

eslint: node_modules
	${ESLINT} --fix ${JS_FILES}
	$(MAKE) -C test/ $@

check-eslint: node_modules
	${ESLINT} ${JS_FILES}
	$(MAKE) -C test/ $@

linter: eslint

check-linter: check-eslint

$(TARGET): $(JS_FILES) node_modules
	rm -f $(TARGET)
	${BROWSERIFY} $(JS_FILES) -o $(TARGET)