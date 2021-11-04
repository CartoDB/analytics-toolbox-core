# Makefile for Redshift modules

SED = sed
AWS = aws
PYTHON2_VERSION = 2.7
PYTHON3_VERSION = 3

RS_SCHEMA = $(RS_SCHEMA_PREFIX)$(MODULE)
RS_PREFIX = $(RS_SCHEMA_PREFIX)

ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

SHARE_CREATE_FILE = $(ROOT_DIR)/sql/_SHARE_CREATE.sql
SHARE_REMOVE_FILE = $(ROOT_DIR)/sql/_SHARE_REMOVE.sql

COMMON_DIR = $(ROOT_DIR)/../../../common
SCRIPTS_DIR = $(ROOT_DIR)/../../../scripts
VENV2_DIR = $(COMMON_DIR)/redshift/venv2
VENV3_DIR = $(COMMON_DIR)/redshift/venv3
VENV2_ACTIVATE = $(VENV2_DIR)/bin/activate
VENV3_ACTIVATE = $(VENV3_DIR)/bin/activate

REPLACEMENTS = -e 's!@@RS_PREFIX@@!$(RS_PREFIX)!g'

AWS_PRINT = tr '\r\n' ' ' | jq -M 'if has("Error") then .["QueryString"],.["Error"] else .["QueryString"] end'
AWS_CHECK = tr '\r\n' ' ' | jq -e 'has("Error") | not' 1>/dev/null || exit 1
AWS_PARSE_OUTPUT = echo $$AWS_OUTPUT | $(AWS_PRINT); echo $$AWS_OUTPUT | $(AWS_CHECK)
AWS_RUN_STATEMENT_SQL = \
    STATEMENT_ID=`$(AWS) redshift-data execute-statement --region $(RS_REGION) --cluster-identifier $(RS_CLUSTER_ID) --database $(RS_DATABASE) --db-user $(RS_USER) --sql "$$STATEMENT_SQL" --output text --query 'Id'`; \
	AWS_OUTPUT=`$(AWS) redshift-data describe-statement --id $$STATEMENT_ID --region $(RS_REGION) --no-cli-pager`; $(AWS_PARSE_OUTPUT)

.SILENT:

.PHONY: help lint lint-fix build test-unit test-integration test-integration-full deploy clean clean-deploy serialize-module serialize-dependency

help:
	echo "Please choose one of the following targets: lint, lint-fix, build, test-unit, test-integration, test-integration-full, deploy, clean, clean-deploy, serialize-module"

lint: venv3
	. $(VENV3_ACTIVATE) && \
	flake8 lib/ test/ --enable-extensions Q0 && \
	deactivate

lint-fix: venv3
	. $(VENV3_ACTIVATE) && \
	brunette lib/ test/ --line-length=88 --single-quotes --quiet && \
	flake8 lib/ test/ --enable-extensions Q0 && \
	deactivate

build:
	rm -rf dist
	mkdir -p dist/$(RS_SCHEMA)Lib
	rsync -a --prune-empty-dirs --include '*/' --include '*.py' --exclude '*'  lib/ dist/$(RS_SCHEMA)Lib/
	cd dist && zip -r $(RS_SCHEMA)Lib *
	rm -rf dist/$(RS_SCHEMA)Lib

test-unit: venv2
	rm -rf lib/$(MODULE)Lib
	mkdir -p lib/$(MODULE)Lib
	rsync -a --prune-empty-dirs --include '*/' --include '*.py' --exclude '*'  lib/ lib/$(MODULE)Lib/
	. $(VENV2_ACTIVATE) && \
	pytest -rP -p no:warnings test/unit/$(TEST) && \
	deactivate || (rm -rf lib/$(MODULE)Lib && exit 1)
	rm -rf lib/$(MODULE)Lib

test-integration: check check-extra venv3
	. $(VENV3_ACTIVATE) && \
	pytest -rP -p no:warnings test/integration/$(TEST) && \
	deactivate

test-integration-full:
	$(MAKE) deploy
	$(MAKE) test-integration || ($(MAKE) clean-deploy && exit 1)
	$(MAKE) clean-deploy

deploy: check
	$(MAKE) storage-upload
	$(MAKE) schema-remove
	$(MAKE) schema-create
	$(MAKE) schema-deploy
	$(MAKE) share-create

clean:
	rm -rf dist
	rm -rf $(VENV2_DIR) $(VENV3_DIR)

clean-deploy: check
	$(MAKE) storage-remove
	$(MAKE) share-remove
	$(MAKE) schema-remove || ((sleep 5 && $(MAKE) schema-remove) || exit 1)

storage-upload: build venv2
	for f in $(wildcard dist/*.zip); do \
		$(AWS) s3 cp $$f $(AWS_S3_BUCKET) || exit 1; \
	done
	for f in $(notdir $(wildcard dist/*.zip)); do \
		STATEMENT_SQL="CREATE OR REPLACE LIBRARY $(RS_SCHEMA) LANGUAGE plpythonu FROM '$(AWS_S3_BUCKET)$(notdir $$f)' CREDENTIALS 'aws_access_key_id=$(AWS_ACCESS_KEY_ID);aws_secret_access_key=$(AWS_SECRET_ACCESS_KEY)';"; $(AWS_RUN_STATEMENT_SQL); \
	done
ifneq ("$(wildcard requirements.txt)","")
	if [ ! -f requirements.txt.shasum ] || [ "`shasum --check requirements.txt.shasum | grep "FAILED"`" ]; then \
		. $(VENV2_ACTIVATE) && \
		bash $(COMMON_DIR)/redshift/libraryinstaller.sh -f requirements.txt && \
		shasum requirements.txt > requirements.txt.shasum && \
		deactivate; \
	fi
endif

storage-remove:
	for f in $(notdir $(wildcard dist/*.zip)); do \
		$(AWS) s3 rm $(AWS_S3_BUCKET)$$f || exit 1; \
	done
	STATEMENT_SQL="DROP LIBRARY $(RS_SCHEMA)"; $(AWS_RUN_STATEMENT_SQL)

schema-create:
	STATEMENT_SQL="CREATE SCHEMA IF NOT EXISTS $(RS_SCHEMA)"; $(AWS_RUN_STATEMENT_SQL)

schema-remove:
	STATEMENT_SQL="DROP SCHEMA IF EXISTS $(RS_SCHEMA) CASCADE"; $(AWS_RUN_STATEMENT_SQL)

schema-deploy:
	for n in `IGNORE="_SHARE_CREATE _SHARE_REMOVE" node $(SCRIPTS_DIR)/sqlsort.js`; do \
		STATEMENT_SQL=`$(SED) $(REPLACEMENTS) $$n`; $(AWS_RUN_STATEMENT_SQL); \
	done

share-create:
ifeq ($(RS_SHARE_ENABLED), 1)
	STATEMENT_SQL=`$(SED) $(REPLACEMENTS) $(SHARE_CREATE_FILE)`; $(AWS_RUN_STATEMENT_SQL)
endif

share-remove:
ifeq ($(RS_SHARE_ENABLED), 1)
	STATEMENT_SQL=`$(SED) $(REPLACEMENTS) $(SHARE_REMOVE_FILE)`; $(AWS_RUN_STATEMENT_SQL)
endif

serialize-dependency: venv2
ifneq ("$(wildcard requirements.txt)","")
	. $(VENV2_ACTIVATE) && \
	bash $(COMMON_DIR)/redshift/libraryinstaller.sh -f requirements.txt -s && \
	deactivate; 
endif

serialize-module: build serialize-dependency
	rm -f dist/module.sql
	echo "DROP SCHEMA IF EXISTS $(RS_SCHEMA) CASCADE;" >> dist/module.sql
	echo "CREATE SCHEMA IF NOT EXISTS $(RS_SCHEMA);" >> dist/module.sql
	for f in $(notdir $(wildcard dist/*.zip)); do \
		LIBRARY_NAME=$$(echo $$f | $(SED) -e 's/Lib.*//g' -e 's/-.*//g'); \
		echo "CREATE OR REPLACE LIBRARY $$LIBRARY_NAME LANGUAGE plpythonu FROM '<AWS_S3_BUCKET>/$(notdir $$f)' CREDENTIALS 'aws_access_key_id=<AWS_ACCESS_KEY_ID>;aws_secret_access_key=<AWS_SECRET_ACCESS_KEY>';" >> dist/module.sql; \
	done
	echo "" >> dist/module.sql;
	for n in `IGNORE="_SHARE_CREATE _SHARE_REMOVE" node $(SCRIPTS_DIR)/sqlsort.js`; do \
	  	$(SED) $(REPLACEMENTS) $$n >> dist/module.sql; \
		echo "" >> dist/module.sql; \
	done

serialize-functions:
	mkdir -p dist
	rm -f dist/funct_names.csv
	MODULE=$(MODULE) IGNORE="_SHARE_CREATE _SHARE_REMOVE" QUALIFY=1 FILE_NAME=$${n} node $(SCRIPTS_DIR)/sqlfunctions.js >> dist/funct_names.csv

venv2:
	virtualenv -p python$(PYTHON2_VERSION) $(VENV2_DIR) -q
	. $(VENV2_ACTIVATE) && \
	python -m pip install -U pip -q 2>/dev/null && \
	pip install -r $(COMMON_DIR)/redshift/python2_requirements.txt -q 2>/dev/null && \
	([ ! -f requirements.txt ] || pip install -r requirements.txt -q 2>/dev/null) && \
	deactivate

venv3:
	virtualenv -p python$(PYTHON3_VERSION) $(VENV3_DIR) -q
	. $(VENV3_ACTIVATE) && \
	python -m pip install -U pip -q && \
	pip install -r $(COMMON_DIR)/redshift/python3_requirements.txt -q && \
	deactivate

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
