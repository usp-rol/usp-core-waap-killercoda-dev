#!/bin/bash

# SPDX-FileCopyrightText: 2025 United Security Providers AG, Switzerland
#
# SPDX-License-Identifier: GPL-3.0-only

#
# intro background script log available at /var/log/killercoda/background0_std(err|out).log

source ~/.scenario_staging/shared-init.sh

# install_backend <namespace> <manifest> <node-port>
install_backend() {
  log_info "installing backend web app in namespace $1 at http://${NODE_IP}:$3..."
  apply_pull_secret "$1"
  kubectl apply -f "${STAGING_DIR}/$2" -n "$1" \
    || log_error "failed to apply backend web app manifest $2 in namespace $1"
  patch_default_sa "$1"
  wait_for_url "http://${NODE_IP}:$3" \
    || log_error "backend web app is not accessible at http://${NODE_IP}:$3 after waiting for 30 attempts"
}

##################################################
# Part 1: setup kyverno
##################################################
log_info "installing kyverno..."
helm repo add kyverno https://kyverno.github.io/kyverno/ \
  || log_error "failed to add kyverno helm repository"
helm repo update \
  || log_error "failed to update helm repositories after adding kyverno helm repository"
helm install kyverno kyverno/kyverno -n "${KYVERNO_NAMESPACE}" --create-namespace \
  --version "${KYVERNO_HELM_VERSION}" --wait --timeout 300s \
  || log_error "failed to install kyverno via helm in namespace ${KYVERNO_NAMESPACE}"

##################################################
# Part 2: setup core waap operator and kyverno policies
##################################################
install_operator
patch_default_sa "${CORE_WAAP_OPERATOR_NAMESPACE}"
log_info "installing kyverno policies for core waap..."
kubectl apply -f "${STAGING_DIR}/${KYVERNO_POLICY_FILE}" \
  || log_error "failed to apply kyverno policies from file ${KYVERNO_POLICY_FILE}"
signal_marker /tmp/.backend_kyverno_installed
signal_marker /tmp/.backend_corewaap_operator_installed

##################################################
# Part 3: setup backend applications
##################################################
install_backend "${JUICESHOP_NAMESPACE}" backend_juiceshop.yaml "${JUICESHOP_NODEPORT}"
install_backend "${HTTPBIN_NAMESPACE}" backend_httpbin.yaml "${HTTPBIN_NODEPORT}"
signal_marker /tmp/.backend_installed
