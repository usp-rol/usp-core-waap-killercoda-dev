# SPDX-FileCopyrightText: 2026 United Security Providers AG, Switzerland
#
# SPDX-License-Identifier: GPL-3.0-only

# usage: make <target> [SCENARIO=usp-core-waap-...]
SCENARIO ?=
SCENARIOS := $(shell jq -r '.items[].path' structure.json)
SHELL_SCRIPTS := $(shell find shared tools local -name '*.sh') local/kc local/runner/kcrc

.PHONY: help sync sync-check lint unit up shell logs down test test-all

help:
	@echo "sync        copy shared/ code into scenario assets"
	@echo "sync-check  verify scenario assets are in sync with shared/"
	@echo "lint        sync-check + shellcheck + unit tests"
	@echo "up|shell|logs|down|test SCENARIO=<dir>   run a scenario in a local kind cluster"
	@echo "test-all    test all scenarios (sequentially)"

sync:
	tools/sync-shared.sh

sync-check:
	tools/sync-shared.sh --check

unit:
	cd local/test && python3 -B -m unittest -v test_run_scenario

lint: sync-check unit
	shellcheck $(SHELL_SCRIPTS)

up shell logs down test:
	@test -n "$(SCENARIO)" || { echo "SCENARIO=<dir> required, one of:"; printf '  %s\n' $(SCENARIOS); exit 2; }
	local/kc $@ $(SCENARIO)

test-all:
	@rc=0; for s in $(SCENARIOS); do local/kc test $$s || rc=1; done; exit $$rc
