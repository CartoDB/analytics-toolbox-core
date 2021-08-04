# Makefile for Redshift modules

SED ?= sed
AWS ?= aws

RS_SCHEMA = $(RS_SCHEMA_PREFIX)$(MODULE)
RS_PREFIX = $(RS_SCHEMA_PREFIX)

SHARE_CREATE_FILE = ./sql/_SHARE_CREATE.sql
SHARE_REMOVE_FILE = ./sql/_SHARE_REMOVE.sql

SCRIPTS_DIR = ../../../scripts

REPLACEMENTS = -e 's!@@RS_PREFIX@@!$(RS_PREFIX)!g'

.SILENT:

.PHONY: help lint lint-fix build test-unit test-integration-dry deploy clean clean-deploy

help:
	echo "Please choose one of the following targets: lint, lint-fix, build, test-unit, test-integration, test-integration-dry, deploy, clean, clean-deploy"

lint:
	flake8 lib/ test/ || exit 0

lint-fix:
	black . --quiet

build:
	rm -rf dist/*
	cd lib && zip -r ../dist/$(RS_SCHEMA) *

test-unit:
	pytest test/unit

test-integration: check check-extra
	pytest test/integration

test-integration-full:
	$(MAKE) deploy
	$(MAKE) test-integration || ($(MAKE) clean-deploy && exit 1)
	$(MAKE) clean-deploy

deploy: check
	$(MAKE) storage-upload
	$(MAKE) schema-create
	$(MAKE) schema-deploy
	$(MAKE) share-create

clean:
	rm -rf dist

clean-deploy: check
	$(MAKE) share-remove
	$(MAKE) schema-remove || ((sleep 5 && $(MAKE) schema-remove) || exit 1)

storage-upload:
	$(MAKE) build
	for f in $(wildcard dist/*.zip); do \
		$(AWS) s3 cp $$f $(AWS_S3_BUCKET) || exit 1; \
	done
	for f in $(notdir $(wildcard dist/*.zip)); do \
		STATEMENT_SQL="CREATE OR REPLACE LIBRARY $(RS_SCHEMA) LANGUAGE plpythonu FROM '$(AWS_S3_BUCKET)$(notdir $$f)' CREDENTIALS 'aws_access_key_id=$(AWS_ACCESS_KEY_ID);aws_secret_access_key=$(AWS_SECRET_ACCESS_KEY)';"; \
		STATEMENT_ID=$$($(AWS) redshift-data execute-statement --region $(RS_REGION) --cluster-identifier $(RS_CLUSTER_ID) --database $(RS_DATABASE) --db-user $(RS_USER) --sql "$$STATEMENT_SQL" --output text --query 'Id') || exit 1; \
		$(AWS) redshift-data describe-statement --id $$STATEMENT_ID --region $(RS_REGION) --no-cli-pager || exit 1; \
	done

schema-create:
	STATEMENT_SQL="CREATE SCHEMA IF NOT EXISTS $(RS_SCHEMA)"; \
	STATEMENT_ID=$$($(AWS) redshift-data execute-statement --region $(RS_REGION) --cluster-identifier $(RS_CLUSTER_ID) --database $(RS_DATABASE) --db-user $(RS_USER) --sql "$$STATEMENT_SQL" --output text --query 'Id') || exit 1; \
	$(AWS) redshift-data describe-statement --id $$STATEMENT_ID --region $(RS_REGION) --no-cli-pager || exit 1;


schema-remove:
	STATEMENT_SQL="DROP SCHEMA IF EXISTS $(RS_SCHEMA) CASCADE"; \
	STATEMENT_ID=$$($(AWS) redshift-data execute-statement --region $(RS_REGION) --cluster-identifier $(RS_CLUSTER_ID) --database $(RS_DATABASE) --db-user $(RS_USER) --sql "$$STATEMENT_SQL" --output text --query 'Id') || exit 1; \
	$(AWS) redshift-data describe-statement --id $$STATEMENT_ID --region $(RS_REGION) --no-cli-pager || exit 1;

schema-deploy:
	for n in `IGNORE="_SHARE_CREATE _SHARE_REMOVE" node $(SCRIPTS_DIR)/sqlsort.js`; do \
		FUNC_QUERY=$$($(SED) $(REPLACEMENTS) $$n); \
		STATEMENT_ID=$$($(AWS) redshift-data execute-statement --region $(RS_REGION) --cluster-identifier $(RS_CLUSTER_ID) --database $(RS_DATABASE) --db-user $(RS_USER) --sql "$$FUNC_QUERY" --output text --query 'Id') || exit 1; \
		$(AWS) redshift-data describe-statement --id $$STATEMENT_ID --region $(RS_REGION) --no-cli-pager || exit 1; \
	done

share-create:
ifeq ($(RS_SHARE_ENABLED), 1)
	FUNC_QUERY=$($(SED) $(REPLACEMENTS) $(SHARE_CREATE_FILE))
	$(AWS) redshift-data execute-statement --region $(RS_REGION) --cluster-identifier $(RS_CLUSTER_ID) --database $(RS_DATABASE) --db-user $(RS_USER) --sql "$$FUNC_QUERY"
endif

share-remove:
ifeq ($(RS_SHARE_ENABLED), 1)
	FUNC_QUERY=$($(SED) $(REPLACEMENTS) $(SHARE_REMOVE_FILE))
	$(AWS) redshift-data execute-statement --region $(RS_REGION) --cluster-identifier $(RS_CLUSTER_ID) --database $(RS_DATABASE) --db-user $(RS_USER) --sql "$$FUNC_QUERY"
endif

check:
ifndef RS_REGION
	$(error RS_REGION is undefined)
endif
ifndef RS_CLUSTER_ID
	$(error RS_CLUSTER_ID is undefined)
endif
ifndef RS_DATABASE
	$(error RS_DATABASE is undefined)
endif
ifndef RS_USER
	$(error RS_USER is undefined)
endif
ifndef AWS_ACCESS_KEY_ID
	$(error AWS_ACCESS_KEY_ID is undefined)
endif
ifndef AWS_SECRET_ACCESS_KEY
	$(error AWS_SECRET_ACCESS_KEY is undefined)
endif
ifndef AWS_S3_BUCKET
	$(error AWS_S3_BUCKET is undefined)
endif

check-extra:
ifndef RS_HOST
	$(error RS_HOST is undefined)
endif
ifndef RS_PASSWORD
	$(error RS_PASSWORD is undefined)
endif
