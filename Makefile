ALL ?= 0
MODULES = \
	h3 \
	placekey \
	quadkey \
  	s2 \
	skel \
	transformation

.PHONY: all build check check-integration check-linter clean deploy linter

all build check check-integration check-linter clean deploy linter:
	for module in $(MODULES); do \
		if [ $(ALL) -eq 1 ] || [ `git diff --name-only | grep -P $${module}'\/.*\.(js|sql)'` ]; then \
			$(MAKE) -C $${module} $@ || exit 1; \
		fi \
	done;