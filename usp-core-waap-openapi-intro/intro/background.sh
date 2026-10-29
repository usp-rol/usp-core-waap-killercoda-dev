#!/bin/bash

# SPDX-FileCopyrightText: 2025 United Security Providers AG, Switzerland
#
# SPDX-License-Identifier: GPL-3.0-only

#
# intro background script log available at /var/log/killercoda/background0_std(err|out).log

source ~/.scenario_staging/shared-init.sh

##################################################
# Part 1: setup swagger petstore backend (https://github.com/swagger-api/swagger-petstore)
##################################################
install_backend_manifest
signal_marker /tmp/.backend_installed

##################################################
# Part 2: setup core waap operator
##################################################
apply_pull_secret "${BACKEND_NAMESPACE}"
patch_default_sa "${BACKEND_NAMESPACE}"
install_operator
copy_to_home "${BACKEND_POD}-core-waap.yaml" openapi-petstore-configmap.yaml
signal_marker /tmp/.operator_installed
