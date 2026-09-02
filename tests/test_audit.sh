#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# Syntax gates
bash -n "$ROOT/scripts/shield.sh"
bash -n "$ROOT/modules/audit.sh"
bash -n "$ROOT/modules/harden.sh"
# Smoke-test the CLI without root mutation.
output="$(VPS_SHIELD_REPORT_DIR="$(mktemp -d)" bash "$ROOT/scripts/shield.sh" audit 2>&1)"
grep -q "VPS Shield" <<<"$output"
grep -Eq "score [0-9]+/100" <<<"$output"
echo "VPS Shield tests: PASS"
