export GIT_DIFF ?= off

.SILENT:

help:
	echo "Please choose one of the following targets: lint, lint-fix, build, test-unit, test-integration, test-integration-dry, deploy, clean, clean-deploy"

lint lint-fix build test-unit test-integration-dry deploy clean clean-deploy:
	if [ "$(CLOUD)" = "bigquery" ] || [ "$(CLOUD)" = "snowflake" ]; then \
		for module in `node scripts/modulesort.js`; do \
			echo "> Module $${module}/$(CLOUD)"; \
			$(MAKE) -C modules/$${module}/$(CLOUD) $@ || exit 1; \
		done; \
	else \
		echo "CLOUD is undefined. Please set one of the following values: bigquery, snowflake"; \
	fi

test-integration:
	$(MAKE) deploy
	$(MAKE) test-integration-dry || ($(MAKE) clean-deploy && exit 1)
	$(MAKE) clean-deploy