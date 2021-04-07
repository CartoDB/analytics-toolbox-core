TARGET = ../h3.js
AUXLIB = h3-js.umd.js
H3_JS_VERSION ?= 3.7.0

ESLINT ?= ./node_modules/eslint/bin/eslint.js
NPM ?= npm
CAT ?= cat

JS_FILES = \
	$(AUXLIB) \
	h3_version.js

LINT_FILES = \
	h3_version.js

.PHONY: all
all: ${TARGET}
$(TARGET): $(JS_FILES)
	rm -f $(TARGET)
	touch $(TARGET)
	for n in $(JS_FILES); do \
		$(CAT) $$n >> $(TARGET) || exit; \
	done

$(AUXLIB):
	bash sync.sh

.PHONY: check
check: node_modules $(AUXLIB)
	$(NPM) test

node_modules: package.json
	$(NPM) ci

.PHONY: clean
clean:
	rm -rf ${TARGET} node_modules/

.PHONY: eslint check-eslint linter check-linter 
eslint: node_modules
	${ESLINT} --fix ${LINT_FILES}

check-eslint: node_modules
	${ESLINT} ${LINT_FILES}

linter: eslint

check-linter: check-eslint