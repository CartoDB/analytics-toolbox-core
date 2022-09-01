# Makefile modules for Redshift

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

CLOUD_DIR ?= $(ROOT_DIR)/..
COMMON_DIR ?= $(CLOUD_DIR)/common

include $(COMMON_DIR)/Makefile

#.SILENT:

.PHONY: help lint build deploy test remove clean

help:
	echo "Available targets: lint build deploy test remove clean"

test: check check-extra venv
	. $(COMMON_DIR)/venv/bin/activate && \
	for module in `ls $(ROOT_DIR)/test`; do \
		echo "> Module $${module}"; \
		pytest -rP -p no:warnings -vv $(ROOT_DIR)/test/$${module} || exit 1; \
	done; \
	deactivate

remove: venv
	. $(COMMON_DIR)/venv/bin/activate && \
	python $(COMMON_DIR)/python_utils/uninstall_functions.py
	deactivate
