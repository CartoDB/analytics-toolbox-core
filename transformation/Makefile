LIBRARY = "library/"
ALL_SUBFOLDERS = $(LIBRARY) "bq/" "sf/"

ENABLED_BQ ?= 0

TARGET = transformation_library.js
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
