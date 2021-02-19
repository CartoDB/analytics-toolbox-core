TARGET = ../placekey_library.js

ESLINT ?= ./node_modules/eslint/bin/eslint.js
NPM ?= npm
CAT ?= cat

all: ${TARGET}

JS_FILES = \
	js/placekey_version.js \
	js/h3-integer.js \
	js/h3-js.umd.js \
	js/placekey.js

LINT_FILES = \
	js/placekey_version.js \
	js/placekey.js

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
	${ESLINT} --fix ${LINT_FILES}

check-eslint: node_modules
	${ESLINT} ${LINT_FILES}

linter: eslint

check-linter: check-eslint

$(TARGET): $(JS_FILES)
	rm -f $(TARGET)
	touch $(TARGET)
	for n in $(JS_FILES); do \
		$(CAT) $$n >> $(TARGET) || exit; \
	done
