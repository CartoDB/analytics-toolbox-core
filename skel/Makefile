DBS = \
	"bq/"

ENABLED_BQ ?= 1

SUBFOLDERS = $(DBS) \
	"library/"

.PHONY: all build check check-integration check-linter clean deploy linter

TARGET = library/library.js

all build:

.PHONY: $(TARGET)
library/library.js:
	$(MAKE) -C library/ all

check check-linter clean linter: $(TARGET)
	for s in $(DBS); do \
		$(MAKE) -C $${s} $@ || exit 1; \
	done;

deploy check-integration:
ifeq (${ENABLED_BQ}, 1)
	$(MAKE) -C bq/ $@
endif
