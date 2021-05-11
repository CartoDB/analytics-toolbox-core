GIT_DIFF ?= off
MODULES = \
	processing

BQ_ENABLED ?= 0

.PHONY: all build lint test-unit test-integration clean deploy
.SILENT: all build lint test-unit test-integration clean deploy

all build lint test-unit test-integration clean deploy:
ifeq ($(BQ_ENABLED), 1)
	for module in $(MODULES); do \
		if [ "$(GIT_DIFF)" = "off" ] || [ `echo "$(GIT_DIFF)" | grep -P $${module}'\/.*(\.js|\.sql|Makefile)' | wc -l` -gt 0 ]; then \
			$(MAKE) -C modules/$${module}/bigquery $@ || exit 1; \
		fi \
	done;
else
	echo "BigQuery disabled. Enable with: BQ_ENABLED=1 make ...";
endif
