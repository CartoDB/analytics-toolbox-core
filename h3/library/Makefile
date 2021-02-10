TARGET = ../h3.js
AUXLIB = h3-js.umd.js

NPM ?= npm
CP ?= cp


.PHONY: all
all: ${TARGET}
$(TARGET): h3-js.umd.js
	$(CP) $(AUXLIB) $(TARGET)

$(AUXLIB):
	bash sync.sh

.PHONY: check
check: node_modules
	$(NPM) test

node_modules: package.json
	$(NPM) ci

.PHONY: clean
clean:
	rm -rf ${TARGET} node_modules/

.PHONY: linter check-linter
linter check-linter: