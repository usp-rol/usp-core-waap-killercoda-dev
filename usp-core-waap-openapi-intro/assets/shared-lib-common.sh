#!/bin/bash

# SPDX-FileCopyrightText: 2026 United Security Providers AG, Switzerland
#
# SPDX-License-Identifier: GPL-3.0-only

# source of truth: shared/common/lib-common.sh (copied into scenario assets by tools/sync-shared.sh)

log_info() {
  echo "****************************************************************"
  echo "*** $(date) : $1"
  echo "****************************************************************"
}

log_error() {
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo "!!! $(date) : ERROR: $1"
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
}

# wait_for_url <url> [max_retries] [--any-status]
# --any-status: accept any http response (i.e. when only a sub-path is routed)
wait_for_url() {
  local url=$1
  local max_retries=${2:-30}
  local any_status=$3
  local retry_interval=5
  local curl_opts=(--fail -s -o /dev/null)
  [ "$any_status" = "--any-status" ] && curl_opts=(-s -o /dev/null)

  for ((i=1; i<=max_retries; i++)); do
    if curl "${curl_opts[@]}" "$url"; then
      log_info "URL $url is accessible"
      return 0
    else
      log_info "Waiting for URL $url to be accessible (attempt $i/$max_retries)..."
      sleep $retry_interval
    fi
  done

  log_error "URL $url is not accessible after $max_retries attempts"
  return 1
}

# signal_marker <file> : indicate setup progress to foreground scripts
signal_marker() {
  touch "$1" && log_info "wrote file $1 to indicate setup progress to foreground process"
}

# copy_to_home <file...> : copy staged files into the user home directory
copy_to_home() {
  local f
  for f in "$@"; do
    cp "${STAGING_DIR}/${f}" ~ || log_error "failed to copy ${f} to user home"
  done
}

# traffic_url <port> : URL a browser uses to access a node-port (killercoda traffic host or localhost)
traffic_url() {
  if [ -f /etc/killercoda/host ]; then
    echo "https://$(sed "s/-PORT/-$1/g" /etc/killercoda/host)"
  else
    echo "http://localhost:$1"
  fi
}

# install_backend_manifest : apply ${BACKEND_POD}.yaml and wait for the backend to be accessible on node-port 30080
install_backend_manifest() {
  log_info "applying backend web app..."
  kubectl apply -f "${STAGING_DIR}/${BACKEND_POD}.yaml" || log_error "failed to apply backend web app manifest"
  log_info "waiting for ${BACKEND_NAMESPACE}/${BACKEND_POD} to be ready..."
  kubectl wait pods "${BACKEND_POD}" -n "${BACKEND_NAMESPACE}" --for='condition=Ready' --timeout=300s \
    || log_error "pod ${BACKEND_POD} in namespace ${BACKEND_NAMESPACE} is not ready after waiting for 300s"
  wait_for_url "http://${NODE_IP}:30080" || log_error "backend web app is not accessible after waiting for 30 attempts"
  log_info "backend web app is accessible"
}

install_java() {
  log_info "installing java runtime environment..."
  sudo apt install -y openjdk-25-jre-headless || log_error "failed to install java runtime environment"
  # java wrapper hiding java 25 sun.misc.Unsafe warnings (caused by protobuf lib within autolearn cli)
  log_info "installing java wrapper ..."
  printf '#!/bin/sh\nexec /usr/bin/java --sun-misc-unsafe-memory-access=allow "$@"\n' \
    | sudo tee /usr/local/bin/java > /dev/null \
    || log_error "failed to install java wrapper"
  sudo chmod +x /usr/local/bin/java || log_error "failed to make java wrapper executable"
}
