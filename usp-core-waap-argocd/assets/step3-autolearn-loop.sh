#!/bin/bash

# SPDX-FileCopyrightText: 2026 United Security Providers AG, Switzerland
#
# SPDX-License-Identifier: GPL-3.0-only

# Redirect stdout/stderr to log file
exec > /var/log/killercoda/background_step3_stdout.log
exec 2> /var/log/killercoda/background_step3_stderr.log

source ~/.scenario_staging/shared-init.sh

_AUTOLEARN_BRANCH="autolearn-tool"
JUICESHOP_NAMESPACE="juiceshop"
JUICESHOP_REPO_BASEDIR="${HOME}/repodata"
JUICESHOP_WAAP_CONFIGFILE="${JUICESHOP_NAMESPACE}/waap.yaml"
JUICESHOP_WAAP_LOGFILE="${JUICESHOP_NAMESPACE}/.waap.log"
WAIT_SECONDS=10

##################################################
# Main procedure
##################################################

log_info "initializing autolearn-branch and check for rule exceptions ..."

# test gogs API availability before proceeding
wait_for_url "http://${NODE_IP}:${GOGS_API_PORT}" \
  || log_error "gogs API is not available at http://${NODE_IP}:${GOGS_API_PORT}"

cd "${JUICESHOP_REPO_BASEDIR}" || log_error "failed to change directory to repodata repository"

# check main and update
git checkout main || log_error "failed to checkout main branch in repodata repository"
git pull || log_error "failed to pull latest changes in repodata repository"
# create new branch for changes
git checkout -b "$_AUTOLEARN_BRANCH" \
  || git checkout "$_AUTOLEARN_BRANCH" \
  || log_error "failed to create/switch to new branch ${_AUTOLEARN_BRANCH} in repodata repository"
while true; do
  log_info "Aquiring Core WAAP logs and running auto-learn tool..."
  # get latest waap logs
  kubectl -n ${JUICESHOP_NAMESPACE} logs deploy/juiceshop-usp-core-waap > "${JUICESHOP_REPO_BASEDIR}/${JUICESHOP_WAAP_LOGFILE}" || log_error "failed to get latest waap logs from juice shop namespace in kubernetes cluster"
  # run auto-learning tool
  _AUTOLEARN_OUTPUT=$(
    java -jar ~/corewaap-autolearn-cli.jar \
      -i "${JUICESHOP_REPO_BASEDIR}/${JUICESHOP_WAAP_CONFIGFILE}" \
      -o "${JUICESHOP_REPO_BASEDIR}/${JUICESHOP_WAAP_CONFIGFILE}" \
      -l "${JUICESHOP_REPO_BASEDIR}/${JUICESHOP_WAAP_LOGFILE}" \
      crs \
      --reduceconfigured \
      --sortexceptions 2>&1
  )
  if [[ "$_AUTOLEARN_OUTPUT" == *" exceptions: 0/0"* ]]; then
    log_info "No new exceptions found by autolearn tool, resetting changes in git repository if any..."
    git checkout -- "${JUICESHOP_REPO_BASEDIR}/${JUICESHOP_WAAP_CONFIGFILE}" || log_error "failed to reset changes in repodata repository"
    log_info "No exceptions found, wating for ${WAIT_SECONDS} seconds before next check..."
    sleep $WAIT_SECONDS
  else
    log_info "Adding new exceptions to git repository"
    # add changes and commit
    git add "${JUICESHOP_REPO_BASEDIR}/${JUICESHOP_WAAP_CONFIGFILE}" || log_error "failed to add changes to git repository"
    git commit -m "exceptions by autolearn tool $(date +%Y-%m-%d\ %H:%M:%S)" || log_error "failed to commit changes to git repository"
    git push origin "$_AUTOLEARN_BRANCH" || log_error "failed to push changes to git repository"
    # create pull request (https://gogs.io/api-reference/introduction)
    # missing support from gogs https://github.com/gogs/gogs/issues/2253"
  fi
done
