export GIT_DIFF ?= off

.SILENT:

.PHONY: help lint lint-fix build test-unit test-integration test-integration-full deploy clean clean-deploy serialize_package

help:
	echo "Please choose one of the following targets: lint, lint-fix, build, test-unit, test-integration, test-integration-full, deploy, clean, clean-deploy, serialize_package"

lint lint-fix build test-unit test-integration deploy clean clean-deploy:
	if [ "$(CLOUD)" = "bigquery" ] || [ "$(CLOUD)" = "snowflake" ]; then \
		for module in `node scripts/modulesort.js`; do \
			echo "> Module $${module}/$(CLOUD)"; \
			$(MAKE) -C modules/$${module}/$(CLOUD) $@ || exit 1; \
		done; \
	else \
		echo "CLOUD is undefined. Please set one of the following values: bigquery, snowflake"; \
	fi

serialize_package: 
	if [ "$(CLOUD)" = "bigquery" ] || [ "$(CLOUD)" = "snowflake" ]; then \
		rm -rf dist/; \
		mkdir dist/; \
		for module in `node scripts/modulesort.js`; do \
			echo "> Module $${module}/$(CLOUD)"; \
			$(MAKE) -C modules/$${module}/$(CLOUD) $@ || exit 1; \
			sed -e "s!@@BQ_LIBRARY_BUCKET@@!@@BQ_LIBRARY_BUCKET@@/lib/$${module}/index.js!g" modules/$${module}/$(CLOUD)/bundle_pkg.sql >> modules/$${module}/$(CLOUD)/bundle_pkg_rep.sql; \
			cat modules/$${module}/$(CLOUD)/bundle_pkg_rep.sql >> dist/bundle_pkg.sql; \
			rm -f modules/$${module}/$(CLOUD)/bundle_pkg.sql modules/$${module}/$(CLOUD)/bundle_pkg_rep.sql; \
			mkdir -p dist/$${module}/ && cp modules/$${module}/$(CLOUD)/dist/index.js dist/$${module}/index.js; \
		done; \
	else \
		echo "CLOUD is undefined. Please set one of the following values: bigquery, snowflake"; \
	fi
	
test-integration-full:
	$(MAKE) deploy
	$(MAKE) test-integration || ($(MAKE) clean-deploy && exit 1)
	$(MAKE) clean-deploy