#!/usr/bin/env bash
set -Eeuo pipefail

backup_file(){
  local src="$1" dir="$2"
  [[ -f "$src" ]] || return 0
  mkdir -p "$dir$(dirname "$src")"
  cp -a "$src" "$dir$src"
}

run_harden(){
  local dry="${1:-1}" backup_root="${2:-/var/lib/vps-shield/backups}"
  local stamp; stamp="$(date -u +%Y%m%dT%H%M%SZ)"; local b="$backup_root/$stamp"
  mkdir -p "$b"
  backup_file /etc/ssh/sshd_config "$b"
  [[ "$dry" -eq 1 ]] && { echo "DRY RUN — proposed conservative changes:"; echo "* Disable SSH root login"; echo "* Disable SSH password authentication"; echo "* Disable X11 forwarding"; echo "* Apply kernel redirect/forwarding baseline when safe"; echo "No changes made."; return 0; }

  echo "Backup: $b"
  local cfg=/etc/ssh/sshd_config
  if [[ -f "$cfg" && -x "$(command -v sshd 2>/dev/null || echo /nonexistent)" ]]; then
    cp -a "$cfg" "$b/etc/ssh/sshd_config.pre"
    set_sshd_option PermitRootLogin no
    set_sshd_option PasswordAuthentication no
    set_sshd_option X11Forwarding no
    if sshd -t; then
      systemctl reload ssh 2>/dev/null || systemctl reload sshd 2>/dev/null || true
      echo "SSH configuration validated and reloaded."
    else
      cp -a "$b/etc/ssh/sshd_config.pre" "$cfg"
      echo "ERROR: sshd validation failed; original configuration restored." >&2
      return 1
    fi
  fi

  if command -v sysctl >/dev/null 2>&1; then
    cat >/etc/sysctl.d/99-vps-shield.conf <<'EOF'
# VPS Shield conservative network baseline
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
EOF
    sysctl --system >/dev/null 2>&1 || true
  fi
  echo "Hardening completed. Run: sudo ./scripts/shield.sh verify"
  echo "$b" > /var/lib/vps-shield/LAST_BACKUP 2>/dev/null || true
}

set_sshd_option(){
  local key="$1" value="$2" file=/etc/ssh/sshd_config
  if grep -Eq "^[[:space:]]*${key}[[:space:]]+" "$file"; then
    sed -i -E "s|^[[:space:]]*${key}[[:space:]].*|${key} ${value}|" "$file"
  else printf '\n%s %s\n' "$key" "$value" >> "$file"; fi
}

rollback_harden(){
  local target="${1:-}"
  [[ -n "$target" ]] || { echo "Usage: rollback <backup-directory>" >&2; return 2; }
  [[ -d "$target" ]] || { echo "Backup directory not found: $target" >&2; return 1; }
  if [[ -f "$target/etc/ssh/sshd_config.pre" ]]; then cp -a "$target/etc/ssh/sshd_config.pre" /etc/ssh/sshd_config; fi
  if [[ -f "$target/etc/ssh/sshd_config" ]]; then cp -a "$target/etc/ssh/sshd_config" /etc/ssh/sshd_config; fi
  if [[ -x "$(command -v sshd 2>/dev/null || echo /nonexistent)" ]] && sshd -t; then systemctl reload ssh 2>/dev/null || systemctl reload sshd 2>/dev/null || true; fi
  echo "Rollback applied from $target."
}
