#!/bin/bash

# SPDX-FileCopyrightText: 2026 United Security Providers AG, Switzerland
#
# SPDX-License-Identifier: GPL-3.0-only

# Copies shared/common/* and the profile selected by SHARED_PROFILE in <scenario>/assets/scenario.env
# into <scenario>/assets/shared-* (killercoda only loads files from within a scenario directory).
#
# usage: tools/sync-shared.sh [--check] [scenario...]   (default: all scenarios with an assets/scenario.env)

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHECK=0
if [ "${1:-}" = "--check" ]; then
  CHECK=1
  shift
fi

if [ $# -eq 0 ]; then
  mapfile -t SCENARIOS < <(cd "$ROOT" && find . -mindepth 3 -maxdepth 3 -path "./*/assets/scenario.env" | cut -d/ -f2 | sort)
else
  SCENARIOS=("${@%/}")
fi

rc=0
declare -A used_profiles=()

for scenario in "${SCENARIOS[@]}"; do
  assets="$ROOT/$scenario/assets"
  env_file="$assets/scenario.env"
  if [ ! -f "$env_file" ]; then
    echo "ERROR: $scenario: missing $env_file" >&2
    rc=1
    continue
  fi
  profile=$(sed -n 's/^SHARED_PROFILE="\{0,1\}\([^"]*\)"\{0,1\}$/\1/p' "$env_file")
  profile_dir="$ROOT/shared/profiles/$profile"
  if [ -z "$profile" ] || [ ! -d "$profile_dir" ]; then
    echo "ERROR: $scenario: SHARED_PROFILE '$profile' not found in shared/profiles/" >&2
    rc=1
    continue
  fi
  used_profiles[$profile]=1

  # expected set of shared-* files: target name -> source file
  declare -A expected=()
  for src in "$ROOT"/shared/common/* "$profile_dir"/*; do
    name="shared-$(basename "$src")"
    if [ -n "${expected[$name]:-}" ]; then
      echo "ERROR: $scenario: $name provided by both shared/common and profile $profile" >&2
      rc=1
    fi
    expected[$name]="$src"
  done

  for name in "${!expected[@]}"; do
    if ! cmp -s "${expected[$name]}" "$assets/$name"; then
      if [ $CHECK -eq 1 ]; then
        echo "OUT OF SYNC: $scenario/assets/$name (source ${expected[$name]#"$ROOT"/})"
        rc=1
      else
        cp "${expected[$name]}" "$assets/$name"
        echo "synced: $scenario/assets/$name"
      fi
    fi
  done
  for existing in "$assets"/shared-*; do
    [ -e "$existing" ] || continue
    name=$(basename "$existing")
    if [ -z "${expected[$name]:-}" ]; then
      if [ $CHECK -eq 1 ]; then
        echo "STALE: $scenario/assets/$name (no longer provided by shared/)"
        rc=1
      else
        rm "$existing"
        echo "removed: $scenario/assets/$name"
      fi
    fi
  done
  unset expected
done

# only meaningful when looking at all scenarios
if [ $# -eq 0 ]; then
  for p in "$ROOT"/shared/profiles/*/; do
    p=$(basename "$p")
    [ -n "${used_profiles[$p]:-}" ] || echo "NOTE: profile shared/profiles/$p is not used by any scenario (consider removing it)"
  done
fi

exit $rc
