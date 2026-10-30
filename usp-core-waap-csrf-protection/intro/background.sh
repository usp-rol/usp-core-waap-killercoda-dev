#!/bin/bash

# SPDX-FileCopyrightText: 2025 United Security Providers AG, Switzerland
#
# SPDX-License-Identifier: GPL-3.0-only

#
# intro background script log available at /var/log/killercoda/background0_std(err|out).log

source ~/.scenario_staging/shared-init.sh

##################################################
# Part 1: setup backend web app
##################################################
install_backend_manifest
log_info "register user in juiceshop..."
curl -H 'Content-Type: application/json' -d '{"email":"user@acme.com","password":"123456","passwordRepeat":"123456","securityQuestion":{"id":2,"question":"Mothers maiden name?","createdAt":"2025-01-15T13:22:31.580Z","updatedAt":"2025-01-15T13:22:31.580Z"},"securityAnswer":"anna"}' -X POST "http://${NODE_IP}:30080/api/Users" -o .registration_step1.txt \
  || log_error "failed to register user in juiceshop"
signal_marker /tmp/.backend_installed

##################################################
# Part 2: setup attacker webapp
##################################################
log_info "applying attacker web page..."
JUICESHOP_DIRECT=$(traffic_host 30080)
JUICESHOP_WAAP=$(traffic_host 30090)
export JUICESHOP_DIRECT JUICESHOP_WAAP
log_info "juiceshop direct host to use in attacker form: $JUICESHOP_DIRECT"
log_info "juiceshop over WAAP host to use in attacker form: $JUICESHOP_WAAP"
envsubst < "${STAGING_DIR}/${ATTACKER_POD}.yaml" > "/tmp/${ATTACKER_POD}.yaml"
kubectl apply -f "/tmp/${ATTACKER_POD}.yaml" || log_error "failed to apply attacker web page manifest"
log_info "waiting for ${ATTACKER_NAMESPACE}/${ATTACKER_POD} to be ready..."
kubectl wait pods "${ATTACKER_POD}" -n "${ATTACKER_NAMESPACE}" --for='condition=Ready' --timeout=300s \
  || log_error "pod ${ATTACKER_POD} in namespace ${ATTACKER_NAMESPACE} is not ready after waiting for 300s"
wait_for_url "http://${NODE_IP}:30070/direct.html" || log_error "attacker web page is not accessible after waiting for 30 attempts"
signal_marker /tmp/.attacker_installed

##################################################
# Part 3: setup core waap operator
##################################################
apply_pull_secret "${BACKEND_NAMESPACE}"
patch_default_sa "${BACKEND_NAMESPACE}"
install_operator
copy_to_home "${BACKEND_POD}-core-waap.yaml"
signal_marker /tmp/.operator_installed
