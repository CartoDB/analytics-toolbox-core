# Makefile for Databricks

ROOT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
ENV_DIR ?= $(ROOT_DIR)/../..



include common/Makefile

#.SILENT:

.PHONY: help lint build deploy test remove clean 

help:
	echo "Please choose one of the following targets: lint build deploy test remove clean"

lint:
	$(MAKE) lint-libraries

lint-libraries:
	$(MAKE) -C libraries/scala lint

build:
	$(MAKE) build-libraries
	$(MAKE) build-modules

build-libraries:
	$(MAKE) -C libraries/scala build
	
build-modules:
	echo "WIP"

deploy:
	$(MAKE) deploy-libraries
	$(MAKE) deploy-modules

deploy-libraries:
	$(MAKE) -C libraries/scala deploy

deploy-modules:
	echo "WIP"

test:
	$(MAKE) test-modules

test-libraries:
	$(MAKE) -C libraries/scala test

test-modules:
	$(MAKE) -C modules test

remove:
	$(MAKE) remove-libraries
	$(MAKE) remove-modules

remove-libraries:
	echo "libraries"

remove-modules:
	$(MAKE) -C modules remove

clean:
	$(MAKE) clean-libraries

clean-libraries:
	$(MAKE) -C libraries/scala clean

clean-modules:
	echo "WIP"

