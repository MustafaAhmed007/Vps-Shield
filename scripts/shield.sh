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
source "$ROOT_DIR/modules/research.sh"
usage(){ cat <<'EOF'
VPS Shield 0.3.0
Usage:
  sudo vps-shield doctor
  sudo vps-shield audit [--json]
  sudo vps-shield harden [--dry-run|--apply]
  sudo vps-shield verify
  sudo vps-shield integrations
  sudo vps-shield research "topic" [--cloud] [--url URL]
  sudo vps-shield rollback <backup-dir>
  sudo vps-shield version
EOF
}
require_root(){ [[ $EUID -eq 0 ]] || { echo "Run as root (sudo)." >&2; exit 1; }; }
doctor(){
  local fail=0
  echo "VPS Shield doctor"
  for cmd in bash awk sed find grep; do command -v "$cmd" >/dev/null 2>&1 && echo "PASS  $cmd" || { echo "FAIL  $cmd missing"; fail=1; }; done
  command -v curl >/dev/null 2>&1 && echo "PASS  curl (research/direct URL available)" || echo "INFO  curl missing (audit still works; research URL/cloud disabled)"
  [[ -d /etc/ssh ]] && echo "PASS  /etc/ssh" || echo "WARN  /etc/ssh not found"
  if [[ -r /proc/1/comm ]]; then echo "INFO  init=$(cat /proc/1/comm)"; fi
  if command -v sshd >/dev/null 2>&1; then echo "PASS  sshd"; else echo "WARN  sshd not found"; fi
  if command -v systemctl >/dev/null 2>&1; then echo "PASS  systemd"; else echo "INFO  systemd not detected"; fi
  if [[ -w /var/lib/vps-shield ]]; then echo "PASS  state directory writable"; else echo "INFO  state directory will be created with sudo"; fi
  return "$fail"
}
case "${1:-}" in
  doctor) require_root; doctor ;;
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
  research)
    require_root; shift; topic="${1:-}"; shift || true; mode="auto"; url=""
    while [[ $# -gt 0 ]]; do case "$1" in --cloud) mode="cloud";; --url) shift; url="${1:-}";; *) echo "Unknown research option: $1" >&2; exit 2;; esac; shift || true; done
    run_research "$topic" "$mode" "$url"
    ;;
  rollback) require_root; rollback_harden "${2:-}" ;;
  version) echo "VPS Shield 0.3.0" ;;
  *) usage; exit 2 ;;
esac
