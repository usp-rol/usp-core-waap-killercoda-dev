#!/bin/bash

# SPDX-FileCopyrightText: 2026 United Security Providers AG, Switzerland
#
# SPDX-License-Identifier: GPL-3.0-only

# source of truth: shared/profiles/core-waap-2.1/wait-for-core-waap-instance.sh (copied into scenario assets by tools/sync-shared.sh)
#
# usage (from a step background script, detached): bash ~/.scenario_staging/shared-wait-for-core-waap-instance.sh <step-number> &
# waits for the user to create the CoreWaapService instance and exposes it via node-port

exec > "/var/log/killercoda/background_step${1}_stdout.log"
exec 2> "/var/log/killercoda/background_step${1}_stderr.log"

source ~/.scenario_staging/shared-init.sh

wait_for_waap_ready "${BACKEND_NAMESPACE}"
expose_waap_nodeport "${BACKEND_NAMESPACE}" "${BACKEND_POD}" 30090 "${WAAP_URL_CHECK:-}"
log_info "background script finished"
