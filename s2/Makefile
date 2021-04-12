DBS = "bq/"
LIBRARY = "library/"
ALL_SUBFOLDERS = $(DBS) $(LIBRARY)

ENABLED_BQ ?= 1
ENABLED_SF ?= 0

TARGET = s2_library.js
.PHONY: all build check check-integration check-linter clean deploy linter $(TARGET)

all build $(TARGET):
	$(MAKE) -C library/ all

check check-linter linter:
	for s in $(LIBRARY); do \
		$(MAKE) -C $${s} $@ || exit 1; \
	done;

clean:
	for s in $(ALL_SUBFOLDERS); do \
		$(MAKE) -C $${s} $@ || exit 1; \
	done;

deploy check-integration:
ifeq (${ENABLED_BQ}, 1)
	$(MAKE) -C bq/ $@
endif
ifeq (${ENABLED_SF}, 1)
	$(MAKE) -C sf/ $@
endif