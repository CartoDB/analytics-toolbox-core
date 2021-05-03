GIT_DIFF ?= off
MODULES = \
	h3 \
	placekey \
	quadkey \
  	s2 \
	skel \
	transformations \
	constructors \
	measurements \
	processing

.PHONY: all build check check-integration check-linter clean deploy linter

all build check check-integration check-linter clean deploy linter:
	for module in $(MODULES); do \
		if [ "$(GIT_DIFF)" = "off" ] || [ `echo "$(GIT_DIFF)" | grep -P $${module}'\/.*(\.js|\.sql|Makefile)' | wc -l` -gt 0 ]; then \
			$(MAKE) -C $${module} $@ || exit 1; \
		fi \
	done;
