#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_DIR="${VPS_SHIELD_REPORT_DIR:-/var/lib/vps-shield/reports}"
BACKUP_DIR="${VPS_SHIELD_BACKUP_DIR:-/var/lib/vps-shield/backups}"
mkdir -p "$REPORT_DIR" "$BACKUP_DIR" 2>/dev/null || true
source "$ROOT_DIR/modules/audit.sh"
source "$ROOT_DIR/modules/harden.sh"
source "$ROOT_DIR/modules/integrations.sh"
usage(){ cat <<'EOF'
VPS Shield 0.2.0
Usage:
  sudo ./scripts/shield.sh audit [--json]
  sudo ./scripts/shield.sh harden [--dry-run|--apply]
  sudo ./scripts/shield.sh verify
  sudo ./scripts/shield.sh integrations
  sudo ./scripts/shield.sh rollback <backup-dir>
  sudo ./scripts/shield.sh version
EOF
}
require_root(){ [[ $EUID -eq 0 ]] || { echo "Run as root (sudo)." >&2; exit 1; }; }
case "${1:-}" in
  audit)
    shift; json=0
    if [[ "${1:-}" == "--json" ]]; then json=1; fi
    run_audit "$json" "$REPORT_DIR"
    ;;
  harden)
    shift; require_root; dry=1
    if [[ "${1:-}" == "--apply" ]]; then dry=0; fi
    if [[ "${1:-}" == "--dry-run" ]]; then dry=1; fi
    run_harden "$dry" "$BACKUP_DIR"
    ;;
  verify) run_audit 0 "$REPORT_DIR" ;;
  integrations) integration_status ;;
  rollback) require_root; rollback_harden "${2:-}" ;;
  version) echo "VPS Shield 0.2.0" ;;
  *) usage; exit 2 ;;
esac
