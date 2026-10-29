# SPDX-FileCopyrightText: 2026 United Security Providers AG, Switzerland
#
# SPDX-License-Identifier: GPL-3.0-only

# killercoda-like "host" used to run scenarios against a local kind cluster
FROM docker.io/library/ubuntu:24.04

ARG KUBECTL_VERSION=v1.34.1
ARG HELM_VERSION=v3.19.0

ENV DEBIAN_FRONTEND=noninteractive
# apt lists are kept on purpose: scenario scripts run "apt install" like on killercoda
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bash-completion ca-certificates curl gettext-base git jq less openjdk-25-jre-headless \
      procps python3 socat sudo vim-tiny \
 && curl -fsSLo /usr/local/bin/kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
 && echo "$(curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256")  /usr/local/bin/kubectl" | sha256sum -c - \
 && chmod +x /usr/local/bin/kubectl \
 && curl -fsSLo /tmp/helm.tgz "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" \
 && echo "$(curl -fsSL "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz.sha256sum" | cut -d' ' -f1)  /tmp/helm.tgz" | sha256sum -c - \
 && tar -xzf /tmp/helm.tgz -C /usr/local/bin --strip-components=1 linux-amd64/helm \
 && rm /tmp/helm.tgz

WORKDIR /root
ENTRYPOINT ["/opt/kc/entrypoint.sh"]
