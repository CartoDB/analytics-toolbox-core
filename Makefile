GIT_DIFF ?= off
BQ_ENABLED ?= 0
SF_ENABLED ?= 0

all build lint test-unit test-integration clean deploy:
ifeq ($(BQ_ENABLED), 1)
	for module in `ls modules`; do \
		if [ "$(GIT_DIFF)" = "off" ] || [ `echo "$(GIT_DIFF)" | grep -P $${module}'\/.*(\.js|\.sql|Makefile)' | wc -l` -gt 0 ]; then \
			$(MAKE) -C modules/$${module}/bigquery $@ || exit 1; \
		fi \
	done;
else
	echo "BigQuery not enabled. Enable with: BQ_ENABLED=1 make ...";
endif
ifeq ($(SF_ENABLED), 1)
	for module in `ls modules`; do \
		if [ "$(GIT_DIFF)" = "off" ] || [ `echo "$(GIT_DIFF)" | grep -P $${module}'\/.*(\.js|\.sql|Makefile)' | wc -l` -gt 0 ]; then \
			$(MAKE) -C modules/$${module}/snowflake $@ || exit 1; \
		fi \
	done;
else
	echo "Snowflake not enabled. Enable with: SF_ENABLED=1 make ...";
endif


.PHONY: all build lint test-unit test-integration clean deploy
.SILENT: all build lint test-unit test-integration clean deploy
