MODULES = \
	h3 \
  quadkey \
	placekey \
	skel

.PHONY: all build check check-integration check-linter clean deploy linter

all build check check-integration check-linter clean deploy linter:
	for module in $(MODULES); do \
		$(MAKE) -C $${module} $@ || exit 1; \
	done;
