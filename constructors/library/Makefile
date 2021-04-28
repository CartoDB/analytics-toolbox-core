TARGET = ../constructors_library.js

ESLINT ?= ./node_modules/eslint/bin/eslint.js
NPM ?= npm
CAT ?= cat

all: $(TARGET)

JS_FILES = \
	constructors/constructors_version.js \

.PHONY: check
check: $(TARGET)
	$(MAKE) -C test/ $@

.PHONY: clean
clean:
	rm -rf $(TARGET) node_modules/
	$(MAKE) -C test/ $@

.PHONY: clang-format check-clang-format eslint check-eslint
node_modules: package.json
	$(NPM) i

eslint: node_modules
	$(ESLINT) --fix $(JS_FILES)

check-eslint: node_modules
	$(ESLINT) $(JS_FILES)

linter: eslint

check-linter: check-eslint

$(TARGET): $(JS_FILES)
	rm -f $(TARGET)
	for n in $(JS_FILES); do \
		$(CAT) $$n >> $(TARGET) || exit; \
	done
