GIT_DIFF ?= off

.SILENT:

help:
	echo "Please choose one of the following targets: lint, lint-fix, build, test-unit, test-integration, test-integration-dry, deploy, clean, clean-deploy"

lint lint-fix build test-unit test-integration test-integration-dry deploy clean clean-deploy:
	if [ "$(CLOUD)" = "bigquery" ] || [ "$(CLOUD)" = "snowflake" ]; then \
		for module in `ls modules`; do \
			if [ "$(GIT_DIFF)" = "off" ] || [ `echo "$(GIT_DIFF)" | grep -P modules/$${module}/$(CLOUD)'\/.*(\.js|\.sql|Makefile)' | wc -l` -gt 0 ]; then \
				if [ -d modules/$${module}/$(CLOUD) ]; then \
					echo "> Module $${module}"; \
					$(MAKE) -C modules/$${module}/$(CLOUD) $@; \
				fi \
			fi \
		done; \
	else \
		echo "CLOUD is undefined. Please set one of the following values: bigquery, snowflake"; \
	fi