MODULES =
BQ_PROJECTID ?= bqcarto

.PHONY: all build check check-integration check-linter clean deploy deploy-bq linter

all build check check-integration check-linter clean deploy deploy-bq linter:
	for module in $(MODULES); do \
		$(MAKE) -C $${module} $@ || exit 1; \
	done;
