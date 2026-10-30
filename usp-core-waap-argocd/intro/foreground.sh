#!/bin/bash

# SPDX-FileCopyrightText: 2025 United Security Providers AG, Switzerland
#
# SPDX-License-Identifier: GPL-3.0-only

FILE=~/.scenario_staging/shared-foreground.sh; while ! test -f ${FILE}; do clear; sleep 0.1; done; bash ${FILE} "Installing ArgoCD application...:/tmp/.backend_argocd_installed" "Installing Gogs application...:/tmp/.backend_gogs_installed" "Installing WAAP Operator...:/tmp/.backend_corewaap_operator_installed" "Installing Demo application...:/tmp/.backend_demo_app_installed" "Finalizing scenario setup...:/tmp/.backend_installed"
