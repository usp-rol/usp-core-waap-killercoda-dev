#!/bin/bash

# SPDX-FileCopyrightText: 2025 United Security Providers AG, Switzerland
#
# SPDX-License-Identifier: GPL-3.0-only

FILE=~/.scenario_staging/shared-foreground.sh; while ! test -f ${FILE}; do clear; sleep 0.1; done; bash ${FILE} "Installing Juice Shop backend...:/tmp/.backend_installed" "Installing USP Core WAAP Operator...:/tmp/.operator_installed" "Configuring CoreWaapService instance...:/tmp/.waap_installed"
