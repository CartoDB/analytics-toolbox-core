GIT_DIFF ?= off

help:
	@echo "Please choose one of the following targets: lint, build, test-unit, test-integration, deploy, clean"

lint build test-unit test-integration deploy clean:
	@if [ "$(CLOUD)" = "bigquery" ] || [ "$(CLOUD)" = "snowflake" ]; then \
		for module in `ls modules`; do \
			if [ "$(GIT_DIFF)" = "off" ] || [ `echo "$(GIT_DIFF)" | grep -P $${module}'\/.*(\.js|\.sql|Makefile)' | wc -l` -gt 0 ]; then \
				$(MAKE) -C modules/$${module}/$(CLOUD) $@; \
			fi \
		done; \
	else \
		echo "CLOUD is undefined. Please set one of the following values: bigquery, snowflake"; \
	fi

.PHONY: lint build test-unit test-integration deploy clean
