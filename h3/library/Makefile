TARGET = ../h3.js
AUXLIB = h3-js.umd.js
H3_JS_VERSION ?= 3.7.0

NPM ?= npm
CP ?= cp


.PHONY: all
all: ${TARGET}
$(TARGET): $(AUXLIB)
	$(CP) $(AUXLIB) $(TARGET)

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

.PHONY: linter check-linter
linter check-linter:
