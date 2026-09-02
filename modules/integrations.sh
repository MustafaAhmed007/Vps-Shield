#!/usr/bin/env bash
set -Eeuo pipefail

# Optional integration probes. These functions are intentionally read-only.
probe_integration(){
  local name="$1" cmd="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '[DETECTED] %-12s %s\n' "$name" "$(command -v "$cmd")"
  else
    printf '[ABSENT]   %-12s not installed\n' "$name"
  fi
}

integration_status(){
  probe_integration docker docker
  probe_integration fail2ban fail2ban-client
  probe_integration crowdsec cscli
  probe_integration trivy trivy
  probe_integration falco falco
  probe_integration wazuh wazuh-control
  if systemctl is-active --quiet cloudflared 2>/dev/null; then echo '[ACTIVE]   cloudflare   cloudflared'; else echo '[ABSENT]   cloudflare   cloudflared service not active'; fi
}
