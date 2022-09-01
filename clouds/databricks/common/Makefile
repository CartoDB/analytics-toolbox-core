# Makefile for Databricks modules

CLOUD = databricks

ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

CLOUD_DIR := $(ROOT_DIR)
COMMON_DIR := $(CLOUD_DIR)/common
SQL_DEPLOY_PATH = /Shared/$(DB_DATASET_PREFIX)carto
ENV_DIR ?= $(ROOT_DIR)/../..
SQL_PATH = $(JAR_DIR)/classes/sql/createUDFs.sql



ifneq (,$(wildcard $(ENV_DIR)/.env))
	include $(ENV_DIR)/.env
	export $(shell sed 's/=.*//' $(ENV_DIR)/.env)
endif

#.SILENT:

.PHONY: check venv

venv:
	virtualenv -p python3 $(COMMON_DIR)/venv -q
	. $(COMMON_DIR)/venv/bin/activate && \
	python -m pip install -U pip -q && \
	pip install -r $(COMMON_DIR)/requirements.txt -q && \
	deactivate

check:
ifndef DB_CLUSTER_ID
	$(error DB_CLUSTER_ID env variable is mandatory)
endif

check-extra:
ifndef DATABRICKS_SERVER_HOSTNAME
	$(error DATABRICKS_SERVER_HOSTNAME is undefined)
endif
ifndef DATABRICKS_HTTP_PATH
	$(error DATABRICKS_HTTP_PATH is undefined)
endif
ifndef DATABRICKS_TOKEN
	$(error DATABRICKS_TOKEN is undefined)
endif
