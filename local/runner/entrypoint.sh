#!/bin/bash

# SPDX-FileCopyrightText: 2026 United Security Providers AG, Switzerland
#
# SPDX-License-Identifier: GPL-3.0-only

# forward 127.0.0.1:<port> to the kind node, so "curl 127.0.0.1:30090" works like on killercoda
for port in ${KC_FORWARD_PORTS}; do
  socat "TCP-LISTEN:${port},bind=127.0.0.1,fork,reuseaddr" "TCP:${KC_NODE_IP}:${port}" &
done

exec sleep infinity
