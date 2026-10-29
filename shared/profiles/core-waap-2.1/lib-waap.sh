#!/bin/bash

# SPDX-FileCopyrightText: 2026 United Security Providers AG, Switzerland
#
# SPDX-License-Identifier: GPL-3.0-only

# source of truth: shared/profiles/core-waap-2.1/lib-waap.sh (copied into scenario assets by tools/sync-shared.sh)

# wait_for_waap_ready <namespace> : wait (endlessly) until a core waap proxy pod is ready
wait_for_waap_ready() {
  log_info "waiting for corewaap instance to be created/ready..."
  until kubectl wait pods -l app.kubernetes.io/name=usp-core-waap-proxy -n "$1" --for='condition=Ready' --timeout=10s; do
    sleep 2
  done
  log_info "corewaap instance found in condition ready"
}

# expose_waap_nodeport <namespace> <backend-pod> [node-port] [--any-status]
expose_waap_nodeport() {
  local ns=$1 pod=$2 port=${3:-30090}
  log_info "creating node-port svc for core waap..."
  cat << EOF | kubectl apply -f -
kind: Service
apiVersion: v1
metadata:
  name: ${pod}-waap-nodeport
  namespace: ${ns}
spec:
  type: NodePort
  selector:
    app.kubernetes.io/instance: ${pod}-usp-core-waap
  ports:
  - name: http
    port: 8080
    targetPort: 8080
    nodePort: ${port}
EOF
  wait_for_url "http://${NODE_IP}:${port}" 30 "$4" || log_error "core waap instance is not accessible after waiting for 30 attempts"
  log_info "core waap instance is accessible via node-port"
}
