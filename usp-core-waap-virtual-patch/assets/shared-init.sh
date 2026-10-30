#!/bin/bash

# SPDX-FileCopyrightText: 2026 United Security Providers AG, Switzerland
#
# SPDX-License-Identifier: GPL-3.0-only

# source of truth: shared/common/init.sh (copied into scenario assets by tools/sync-shared.sh)
#
# usage (in scenario scripts): source ~/.scenario_staging/shared-init.sh
# loads common functions, scenario settings (scenario.env) and the selected core waap profile

STAGING_DIR="${STAGING_DIR:-$HOME/.scenario_staging}"

source "${STAGING_DIR}/shared-lib-common.sh"
source "${STAGING_DIR}/scenario.env"
source "${STAGING_DIR}/shared-profile.env"
source "${STAGING_DIR}/shared-lib-operator.sh"
source "${STAGING_DIR}/shared-lib-waap.sh"

# killercoda node ip (overridden by KC_NODE_IP when running in a local kind cluster)
NODE_IP="${KC_NODE_IP:-${NODE_IP:-172.30.1.2}}"
export NODE_IP
