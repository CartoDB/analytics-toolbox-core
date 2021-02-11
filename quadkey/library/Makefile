TARGET = ../quadkey_library.js

ESLINT ?= ./node_modules/eslint/bin/eslint.js
NPM ?= npm
CAT ?= cat

all: ${TARGET}

JS_FILES = \
	js/quadkey.js \
	js/quadkey_version.js \
	js/tilecover.js

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

check-eslint: node_modules
	${ESLINT} ${JS_FILES}

linter: eslint

check-linter: check-eslint

$(TARGET): $(JS_FILES)
	rm -f $(TARGET)
	touch $(TARGET)
	for n in $(JS_FILES); do \
		$(CAT) $$n >> $(TARGET) || exit; \
	done
