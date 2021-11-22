export GIT_DIFF ?= off

.SILENT:

.PHONY: help lint lint-fix build test-unit test-integration test-integration-full deploy clean clean-deploy

help:
	echo "Please choose one of the following targets: lint, lint-fix, build, test-unit, test-integration, test-integration-full, deploy, clean, clean-deploy"

lint lint-fix build test-unit test-integration deploy clean clean-deploy:
	if [ "$(CLOUD)" = "bigquery" ] || [ "$(CLOUD)" = "snowflake" ] || [ "$(CLOUD)" = "redshift" ]; then \
		for module in `node scripts/modulesort.js`; do \
			echo "\n> Module $${module}/$(CLOUD)"; \
			$(MAKE) -C modules/$${module}/$(CLOUD) $@ || exit 1; \
		done; \
	else \
		echo "CLOUD is undefined. Please set one of the following values: bigquery, snowflake, redshift"; \
	fi

test-integration-full:
	$(MAKE) deploy
	$(MAKE) test-integration || ($(MAKE) clean-deploy && exit 1)
	$(MAKE) clean-deploy
