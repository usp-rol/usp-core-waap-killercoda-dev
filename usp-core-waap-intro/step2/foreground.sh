#!/bin/bash

# SPDX-FileCopyrightText: 2025 United Security Providers AG, Switzerland
#
# SPDX-License-Identifier: GPL-3.0-only

FILE=~/.scenario_staging/shared-foreground.sh; while ! test -f ${FILE}; do clear; sleep 0.1; done; bash ${FILE} "Waiting for USP Core WAAP operator installation to be finished...:/tmp/.operator_installed" \
  && { kubectl wait pods --all -n usp-core-waap-operator --for='condition=Ready' --timeout=60s &>/dev/null || echo "ERROR: core waap operator installation did not succeed!"; }
