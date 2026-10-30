#!/bin/bash

# SPDX-FileCopyrightText: 2025 United Security Providers AG, Switzerland
#
# SPDX-License-Identifier: GPL-3.0-only

#
# intro background script log available at /var/log/killercoda/background0_std(err|out).log

source ~/.scenario_staging/shared-init.sh

GOGS_API_URL="http://${NODE_IP}:${GOGS_API_PORT}/api/v1"
GOGS_REPO_URL="http://${NODE_IP}:${GOGS_API_PORT}/${GOGS_USER}/${GOGS_REPO}.git"
cd "${STAGING_DIR}" || exit 1

##################################################
# Part 1: setup argocd backend application
##################################################
log_info "installing argocd..."
kubectl create namespace "${ARGOCD_NAMESPACE}" || log_error "failed to create namespace ${ARGOCD_NAMESPACE}, it might already exist, proceeding with installation"
kubectl apply -n "${ARGOCD_NAMESPACE}" --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
apply_pull_secret "${ARGOCD_NAMESPACE}"
# install argocd cli
curl --fail -sSL -o argocd-linux-amd64 "${ARGOCD_CLI_DOWNLOAD_URL}" \
  || log_error "failed to download argocd cli from ${ARGOCD_CLI_DOWNLOAD_URL}"
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd || log_error "failed to install argocd cli to /usr/local/bin/argocd"
rm argocd-linux-amd64
kubectl -n "${ARGOCD_NAMESPACE}" wait --all --for=condition=Ready --timeout 300s pod \
  || log_error "argocd k8s installation is not ready after waiting for 300s"
# argocd cli login
kubectl config set-context --current --namespace="${ARGOCD_NAMESPACE}"
argocd login --core || log_error "failed to login to argocd CLI"
# reconfiguring argocd to insecure mode is required to access http port (for killercoda for example)
kubectl patch configmap argocd-cmd-params-cm -n "${ARGOCD_NAMESPACE}" \
  --type merge \
  -p '{"data":{"server.insecure":"true"}}'
kubectl rollout restart deployment argocd-server -n "${ARGOCD_NAMESPACE}"
kubectl -n "${ARGOCD_NAMESPACE}" wait --all --for=condition=Ready --timeout 300s pod \
  || log_error "argocd k8s installation is not ready after waiting for 300s after patching configmap"
# patch svc to be of type NodePort
kubectl patch svc argocd-server \
  --namespace "${ARGOCD_NAMESPACE}" \
  --patch "{\"spec\":{\"type\":\"NodePort\",\"ports\":[{\"port\":80,\"nodePort\":${ARGOCD_API_PORT}}]}}"
wait_for_url "http://${NODE_IP}:${ARGOCD_API_PORT}" \
  || log_error "argocd API is not available at http://${NODE_IP}:${ARGOCD_API_PORT}/api/v1"
signal_marker /tmp/.backend_argocd_installed

##################################################
# Part 2: setup gogs backend application
##################################################
log_info "installing gogs..."
kubectl create namespace "${GOGS_NAMESPACE}" || log_error "failed to create namespace ${GOGS_NAMESPACE}"
# shellcheck disable=SC2016 # only substitute NODE_IP
envsubst '${NODE_IP}' < ./gogs.yaml | kubectl apply -n "${GOGS_NAMESPACE}" -f - || log_error "failed to apply gogs manifests to namespace ${GOGS_NAMESPACE}"
kubectl wait pods -l app=gogs -n "${GOGS_NAMESPACE}" --for='condition=Ready' --timeout=300s \
  || log_error "gogs k8s installation is not ready after waiting for 300s"
kubectl exec -n "${GOGS_NAMESPACE}" deployment/gogs -- /app/gogs/gogs admin create-user --name "${GOGS_USER}" --password "${GOGS_PASSWORD}" --email "${GOGS_EMAIL}" \
  || log_error "failed to create initial gogs user ${GOGS_USER} via gogs admin CLI"

##################################################
# Part 3: initialize gogs repository and webhook
##################################################
log_info "initializing gogs repository and configure webhook URL ..."
wait_for_url "http://${NODE_IP}:${GOGS_API_PORT}" \
  || log_error "gogs API is not available at http://${NODE_IP}:${GOGS_API_PORT}"
GOGS_TOKEN=$(curl --fail -s -u "${GOGS_USER}:${GOGS_PASSWORD}" -X POST "${GOGS_API_URL}/users/${GOGS_USER}/tokens" -H "Content-Type: application/json" -d "{\"name\":\"setup_token\"}" | jq -r '.sha1')
test -n "$GOGS_TOKEN" && log_info "obtained gogs token for user ${GOGS_USER}" || log_error "failed to obtain gogs token for user ${GOGS_USER}"
curl --fail -v -X POST "${GOGS_API_URL}/user/repos" \
  -H "Authorization: token ${GOGS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"${GOGS_REPO}\"}" \
  || log_error "failed to create gogs repository ${GOGS_REPO}"
curl --fail -v -X POST "${GOGS_API_URL}/repos/${GOGS_USER}/${GOGS_REPO}/hooks" \
  -H "Authorization: token ${GOGS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"type\":\"gogs\",\"active\":true,\"config\":{\"url\":\"http://${NODE_IP}:${ARGOCD_API_PORT}/api/webhook\",\"content_type\":\"json\"},\"events\":[\"push\"]}" \
  || log_error "failed to create webhook for gogs repository ${GOGS_REPO}"
signal_marker /tmp/.backend_gogs_installed

##################################################
# Part 4: create argocd corewaap operator application
##################################################
log_info "creating argocd application for usp core waap operator ..."
apply_pull_secret "${CORE_WAAP_OPERATOR_NAMESPACE}"
argocd repo add "${CONTAINER_REGISTRY}" \
  --project "${ARGOCD_PROJECT}" \
  --username "${REGISTRY_USER}" \
  --password "$(registry_password)" \
  --name "${ARGOCD_REPO_NAME}" \
  --type helm \
  --enable-oci \
  || log_error "failed to add argocd helm repository ${CONTAINER_REGISTRY}"
envsubst < ./shared-operator-helm-template.yaml > corewaap-operator-argocd-values.yaml
argocd app create "${CORE_WAAP_OPERATOR_NAMESPACE}" \
  --project "${ARGOCD_PROJECT}" \
  --repo "${CONTAINER_REGISTRY}" \
  --revision "${CORE_WAAP_HELM_VERSION}" \
  --helm-chart "${CORE_WAAP_HELM_CHART}" \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace "${CORE_WAAP_OPERATOR_NAMESPACE}" \
  --values-literal-file corewaap-operator-argocd-values.yaml \
  --sync-option CreateNamespace=true \
  --sync-policy automated \
  || log_error "failed to create argocd application ${CORE_WAAP_OPERATOR_NAMESPACE} for usp core waap operator helm chart ${CORE_WAAP_HELM_CHART}"
signal_marker /tmp/.backend_corewaap_operator_installed

##################################################
# Part 5: install java and autolearning cli
##################################################
install_java
log_info "waiting for corewaap operator to be ready ..."
kubectl -n "${CORE_WAAP_OPERATOR_NAMESPACE}" wait --for=condition=available deployment/core-waap-operator --timeout=300s \
  || log_error "waiting for corewaap operator deployment timed out"
install_autolearn_cli "${HOME}/corewaap-autolearn-cli.jar"

##################################################
# Part 6: initialize git cli env and repository
##################################################
log_info "configuring local git cli and pushing initial repodata to gogs repository ..."
git config --global init.defaultBranch main
git config --global user.name "${GOGS_USER}"
git config --global user.email "${GOGS_EMAIL}"
cd ~/repodata || log_error "failed to change directory to ~/repodata for git repository initialization and push to gogs"
echo "*.log" > .gitignore || log_error "failed to create .gitignore file in ~/repodata for git repository initialization"
git init || log_error "failed to initialize git repository in ~/repodata"
git add . || log_error "failed to add repodata files to git repository in ~/repodata"
git commit -m 'intitial repo commit' || log_error "failed to commit repodata files to git repository in ~/repodata"
git remote add origin "http://${GOGS_USER}:${GOGS_PASSWORD}@${NODE_IP}:${GOGS_API_PORT}/${GOGS_USER}/${GOGS_REPO}.git" \
  || log_error "failed to add gogs repository as git remote origin"
git push -u origin main \
  || log_error "failed to push initial repodata to gogs repository"
cd "${STAGING_DIR}" || log_error "failed to change back to staging directory"

##################################################
# Part 7: create juiceshop/corewaap app in argocd
##################################################
log_info "creating juiceshop/corewaap app in argocd ..."
apply_pull_secret "${ARGOCD_DEMO_APP_NAMESPACE}"
argocd app create "${ARGOCD_DEMO_APP_NAME}" \
  --project "${ARGOCD_PROJECT}" \
  --path "${ARGOCD_DEMO_APP_PATH}" \
  --repo "${GOGS_REPO_URL}" \
  --dest-namespace "${ARGOCD_DEMO_APP_NAMESPACE}" \
  --dest-server https://kubernetes.default.svc \
  --revision main \
  --sync-policy automated \
  || log_error "failed to create argocd application ${ARGOCD_DEMO_APP_NAME} for demo app in path ${ARGOCD_DEMO_APP_PATH} of repository"
signal_marker /tmp/.backend_demo_app_installed
signal_marker /tmp/.backend_installed
