#!/bin/bash

# SPDX-FileCopyrightText: 2025 United Security Providers AG, Switzerland
#
# SPDX-License-Identifier: GPL-3.0-only

#
# intro background script log available at /var/log/killercoda/background0_std(err|out).log

source ~/.scenario_staging/shared-init.sh

##################################################
# Part 1: setup prometheus - https://artifacthub.io/packages/helm/prometheus-community/prometheus
##################################################
log_info "installing prometheus..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || exit 1
helm repo update || exit 1
helm install --create-namespace --namespace "${BACKEND_NAMESPACE}" \
  --set server.service.type=NodePort \
  --set server.service.nodePort=30080 \
  prometheus prometheus-community/prometheus || exit 1
PROMETHEUS_POD=$(kubectl get pods --namespace "${BACKEND_NAMESPACE}" -l "app.kubernetes.io/name=prometheus,app.kubernetes.io/instance=prometheus" -o jsonpath="{.items[0].metadata.name}")
log_info "waiting for ${BACKEND_NAMESPACE}/${PROMETHEUS_POD} to be ready..."
kubectl wait pods "${PROMETHEUS_POD}" -n "${BACKEND_NAMESPACE}" --for='condition=Ready' --timeout=300s \
  || log_error "pod ${PROMETHEUS_POD} in namespace ${BACKEND_NAMESPACE} is not ready after waiting for 300s"
wait_for_url "http://${NODE_IP}:30080" || log_error "backend web app is not accessible after waiting for 30 attempts"
signal_marker /tmp/.backend_installed

##################################################
# Part 2: setup core waap operator
##################################################
apply_pull_secret "${BACKEND_NAMESPACE}"
patch_default_sa "${BACKEND_NAMESPACE}"
install_operator
copy_to_home "${BACKEND_POD}-core-waap.yaml"
signal_marker /tmp/.operator_installed
