#!/bin/bash

# SPDX-FileCopyrightText: 2026 United Security Providers AG, Switzerland
#
# SPDX-License-Identifier: GPL-3.0-only

# source of truth: shared/common/foreground.sh (copied into scenario assets by tools/sync-shared.sh)
#
# usage: bash shared-foreground.sh "<message>:<marker-file>[,<marker-file>...]" ...
# prints each message and waits until all its marker files (written by background scripts) exist

clear

for item in "$@"; do
  msg="${item%%:*}"
  IFS=',' read -r -a markers <<< "${item#*:}"
  echo -n "${msg}"
  for marker in "${markers[@]}"; do
    while [ ! -f "${marker}" ]; do
      echo -n '.'
      sleep 1
    done
  done
  echo " done"
done
echo
echo "*** Scenario ready ***"
