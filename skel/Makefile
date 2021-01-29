DBS = \
	"bq/"

ENABLED_BQ ?= 1

SUBFOLDERS = $(DBS) \
	"library/"

TARGET = skel_library.js
.PHONY: all build check check-integration check-linter clean deploy linter $(TARGET)

.PHONY: 
library/library.js:
	$(MAKE) -C library/ all

check check-linter clean linter: $(TARGET)
	for s in $(SUBFOLDERS); do \
		$(MAKE) -C $${s} $@ || exit 1; \
	done;

deploy check-integration:
ifeq (${ENABLED_BQ}, 1)
	$(MAKE) -C bq/ $@
endif
