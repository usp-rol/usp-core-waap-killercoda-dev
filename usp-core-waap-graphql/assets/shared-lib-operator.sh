#!/bin/bash

# SPDX-FileCopyrightText: 2026 United Security Providers AG, Switzerland
#
# SPDX-License-Identifier: GPL-3.0-only

# source of truth: shared/profiles/core-waap-2.1/lib-operator.sh (copied into scenario assets by tools/sync-shared.sh)

registry_password() {
  echo "${REGISTRY_PASSWORD_B64}" | base64 -d
}

registry_login() {
  log_info "login to helm registry..."
  registry_password | helm registry login "${CONTAINER_REGISTRY}" --username "${REGISTRY_USER}" --password-stdin \
    || log_error "failed to login to helm registry ${CONTAINER_REGISTRY} with user ${REGISTRY_USER}"
}

# apply_pull_secret <namespace...> : create namespace (if missing) and registry pull secret
apply_pull_secret() {
  local ns
  for ns in "$@"; do
    kubectl create namespace "${ns}" --dry-run=client -o yaml | kubectl apply -f - \
      || log_error "failed to create namespace ${ns}"
    kubectl create secret docker-registry "${PULL_SECRET_NAME}" -n "${ns}" \
      --docker-server="${CONTAINER_REGISTRY}" \
      --docker-username="${REGISTRY_USER}" \
      --docker-password="$(registry_password)" \
      --dry-run=client -o yaml | kubectl apply -f - \
      || log_error "failed to apply image pull secret in namespace ${ns}"
  done
}

# patch_default_sa <namespace...> : let pods using the default service account pull from the registry
patch_default_sa() {
  local ns
  for ns in "$@"; do
    log_info "patch default serviceaccount in ${ns} namespace..."
    kubectl patch serviceaccount default -n "${ns}" -p "{\"imagePullSecrets\": [{\"name\": \"${PULL_SECRET_NAME}\"}]}" \
      || log_error "failed to patch default serviceaccount in ${ns} namespace"
  done
}

# install_operator : install the core waap operator helm chart (incl. registry login and pull secret)
install_operator() {
  registry_login
  log_info "prepare core waap operator setup..."
  apply_pull_secret "${CORE_WAAP_OPERATOR_NAMESPACE}"
  log_info "apply defined variables in helm-values template..."
  envsubst < "${STAGING_DIR}/shared-operator-helm-template.yaml" > "${STAGING_DIR}/operator-helm-values.yaml"
  log_info "install operator via helm chart version ${CORE_WAAP_HELM_VERSION}..."
  helm install \
    usp-core-waap-operator \
    "oci://${CONTAINER_REGISTRY}/${CORE_WAAP_HELM_CHART}" \
    --version "${CORE_WAAP_HELM_VERSION}" \
    --values "${STAGING_DIR}/operator-helm-values.yaml" \
    --namespace "${CORE_WAAP_OPERATOR_NAMESPACE}" \
    || log_error "failed to install operator using chart ${CORE_WAAP_HELM_CHART} version ${CORE_WAAP_HELM_VERSION}"
  kubectl wait crd/corewaapservices.waap.core.u-s-p.ch --for=condition=Established --timeout=120s \
    || log_error "core waap CRD not established after waiting for 120s"
  log_info "core waap operator setup finished"
}

# install_autolearn_cli <target-file> : download the auto-learning cli matching this profile
install_autolearn_cli() {
  local target=$1
  local url="https://docs.united-security-providers.ch/usp-core-waap/${CORE_WAAP_DOCS_VERSION}/files/waap-lib-autolearn-cli-${CORE_WAAP_AUTOLEARN_CLI_VERSION}.jar"
  log_info "downloading auto-learning cli tool version ${CORE_WAAP_AUTOLEARN_CLI_VERSION}..."
  curl --fail -so "${target}" "${url}" \
    || log_error "failed to download autolearn-cli for version ${CORE_WAAP_AUTOLEARN_CLI_VERSION} from ${url}"
  test -s "${target}"
}
