export GIT_DIFF ?= off

.SILENT:

.PHONY: help lint lint-fix build test-unit test-integration-dry deploy clean clean-deploy

help:
	echo "Please choose one of the following targets: lint, lint-fix, build, test-unit, test-integration, test-integration-dry, deploy, clean, clean-deploy, serialize_package"

lint lint-fix build test-unit test-integration-dry deploy clean clean-deploy serialize_package:
	if [ "$(CLOUD)" = "bigquery" ] || [ "$(CLOUD)" = "snowflake" ]; then \
		if [ "$@" = "serialize_package" ]; then \
			rm -rf dist/; \
			mkdir dist/; \
		fi; \
		for module in `node scripts/modulesort.js`; do \
			echo "> Module $${module}/$(CLOUD)"; \
			$(MAKE) -C modules/$${module}/$(CLOUD) $@ || exit 1; \
			if [ "$@" = "serialize_package" ]; then \
				sed -e "s!@@BQ_LIBRARY_BUCKET@@!@@BQ_LIBRARY_BUCKET@@/lib/$${module}/index.js!g" modules/$${module}/$(CLOUD)/bundle_pkg.sql >> modules/$${module}/$(CLOUD)/bundle_pkg_rep.sql; \
				cat modules/$${module}/$(CLOUD)/bundle_pkg_rep.sql >> dist/bundle_pkg.sql; \
				rm -f modules/$${module}/$(CLOUD)/bundle_pkg.sql modules/$${module}/$(CLOUD)/bundle_pkg_rep.sql; \
				mkdir -p dist/$${module}/ && cp modules/$${module}/$(CLOUD)/dist/index.js dist/$${module}/index.js; \
			fi; \
		done; \
	else \
		echo "CLOUD is undefined. Please set one of the following values: bigquery, snowflake"; \
	fi

test-integration:
	$(MAKE) deploy
	$(MAKE) test-integration-dry || ($(MAKE) clean-deploy && exit 1)
	$(MAKE) clean-deploy