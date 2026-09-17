#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Prints the first-run welcome from .agent/welcome.md. With --slow, reveals it
# line by line for terminals that show output live. Pure decoration; nothing
# depends on it.
set -u
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
delay=0
[ "${1:-}" = "--slow" ] && delay=0.04
awk '/^```$/{f=!f; next} f' "$here/welcome.md" | while IFS= read -r line; do
  printf '%s\n' "$line"
  [ "$delay" != 0 ] && sleep "$delay"
done
exit 0
