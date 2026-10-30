#!/bin/bash

# SPDX-FileCopyrightText: 2025 United Security Providers AG, Switzerland
#
# SPDX-License-Identifier: GPL-3.0-only

#
# intro background script log available at /var/log/killercoda/background0_std(err|out).log

source ~/.scenario_staging/shared-init.sh

##################################################
# Part 1: setup lldap backend (https://github.com/lldap/lldap / https://artifacthub.io/packages/helm/alexmorbo-lldap/lldap)
##################################################
log_info "installing lldap backend app..."
helm upgrade --install \
  --create-namespace \
  -n "${BACKEND_NAMESPACE}" \
  "${BACKEND_POD}" \
  oci://ghcr.io/alexmorbo/helm-charts/lldap \
  --set 'secret.lldapUserPass=insecure' || exit 1
log_info "waiting for ${BACKEND_NAMESPACE}/${BACKEND_POD} to be ready..."
kubectl wait pods -l app.kubernetes.io/name=lldap -n "${BACKEND_NAMESPACE}" --for='condition=Ready' --timeout=300s \
  || log_error "lldap pod in namespace ${BACKEND_NAMESPACE} is not ready after waiting for 300s"
log_info "creating node-port svc for lldap backend..."
cat << EOT | kubectl apply -f -
kind: Service
apiVersion: v1
metadata:
  name: ${BACKEND_POD}-nodeport
  namespace: ${BACKEND_NAMESPACE}
spec:
  type: NodePort
  selector:
    app.kubernetes.io/name: lldap
  ports:
  - name: http
    port: ${BACKEND_PORT}
    targetPort: ${BACKEND_PORT}
    nodePort: 30080
EOT
wait_for_url "http://${NODE_IP}:30080" || log_error "backend web app is not accessible after waiting for 30 attempts"
log_info "query JWT authentication token..."
LLDAP_TOKEN=$(curl -s -X POST -H 'Content-Type: application/json' "http://${NODE_IP}:30080/auth/simple/login" -d '{"username":"admin", "password":"insecure"}' | jq -r '.token')
if [ -z "$LLDAP_TOKEN" ] || [ "$LLDAP_TOKEN" == "null" ]; then
  log_error "LLDAP backend setup failed - please restart the scenario (if consistent report this error on scenario overview page)"
  exit 1
else
  echo "export LLDAP_TOKEN=$LLDAP_TOKEN" > ~/.ldap_token || exit 1
fi
signal_marker /tmp/.backend_installed

##################################################
# Part 2: setup core waap operator
##################################################
apply_pull_secret "${BACKEND_NAMESPACE}"
patch_default_sa "${BACKEND_NAMESPACE}"
install_operator
copy_to_home "${BACKEND_POD}-core-waap.yaml" "${BACKEND_POD}-schema.graphql"

##################################################
# Part 3: install java and download Auto-Learning Tool
##################################################
install_java
install_autolearn_cli ~/waap-lib-autolearn-cli.jar || exit 1
signal_marker /tmp/.operator_installed
