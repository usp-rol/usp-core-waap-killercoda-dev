#!/bin/bash

# SPDX-FileCopyrightText: 2025 United Security Providers AG, Switzerland
#
# SPDX-License-Identifier: GPL-3.0-only

FILE=~/.scenario_staging/shared-foreground.sh; while ! test -f ${FILE}; do clear; sleep 0.1; done; bash ${FILE} "Installing Core WAAP Operator...:/tmp/.backend_corewaap_operator_installed" "Installing Backend Applications...:/tmp/.backend_installed"
