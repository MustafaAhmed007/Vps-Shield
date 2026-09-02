#!/usr/bin/env bash
# VPS Shield audit engine. Source from scripts/shield.sh.
set -Eeuo pipefail

score=100
pass_count=0; fail_count=0; warn_count=0
RESULTS=()

record(){
  local severity="$1" id="$2" message="$3" remediation="${4:-}"
  RESULTS+=("$severity|$id|$message|$remediation")
  case "$severity" in PASS) ((pass_count+=1));; FAIL) ((fail_count+=1)); score=$((score-8));; WARN) ((warn_count+=1)); score=$((score-3));; esac
}

has(){ command -v "$1" >/dev/null 2>&1; }

check_ssh(){
  if ! has sshd; then record WARN sshd "OpenSSH server binary not found; SSH checks skipped" "Install/verify openssh-server if this host should provide SSH"; return; fi
  local cfg; cfg="$(sshd -T 2>/dev/null || true)"
  [[ -n "$cfg" ]] || { record WARN ssh_effective "Could not read effective sshd configuration" "Run sshd -T as root and inspect syntax"; return; }
  grep -qi '^permitrootlogin no$' <<<"$cfg" && record PASS ssh_root "Root SSH login is disabled" || record FAIL ssh_root "Root SSH login is enabled or not explicitly disabled" "Set PermitRootLogin no after confirming a non-root admin path"
  grep -qi '^passwordauthentication no$' <<<"$cfg" && record PASS ssh_password "SSH password authentication is disabled" || record WARN ssh_password "SSH password authentication is enabled" "Prefer key/certificate authentication and disable password authentication after testing"
  grep -qi '^x11forwarding no$' <<<"$cfg" && record PASS ssh_x11 "X11 forwarding is disabled" || record WARN ssh_x11 "X11 forwarding is enabled" "Set X11Forwarding no unless explicitly required"
  local files=(/etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf)
  local f; for f in "${files[@]}"; do [[ -f "$f" ]] || continue; stat -c '%a' "$f" 2>/dev/null | grep -Eq '^(600|640|644)$' && continue; record WARN ssh_file "$f has unusual permissions" "Restrict SSH configuration permissions"; done
}

check_firewall(){
  if has ufw && ufw status 2>/dev/null | grep -q 'Status: active'; then record PASS firewall "UFW is active"; return; fi
  if has firewall-cmd && firewall-cmd --state 2>/dev/null | grep -q running; then record PASS firewall "firewalld is active"; return; fi
  if has nft && nft list ruleset 2>/dev/null | grep -qE '(^|[[:space:]])(table|chain)[[:space:]]'; then record PASS firewall "nftables has a ruleset"; return; fi
  if has iptables && iptables -S 2>/dev/null | grep -qE '^-P (INPUT|FORWARD) (DROP|REJECT)'; then record PASS firewall "iptables has restrictive default policy"; return; fi
  record FAIL firewall "No active restrictive host firewall detected" "Enable and verify a firewall appropriate for the distribution"
}

check_services(){
  if has ss; then
    local count; count="$(ss -lntupH 2>/dev/null | wc -l || true)"
    [[ "$count" -lt 20 ]] && record PASS listeners "Listening socket count: $count" || record WARN listeners "Many listening sockets detected: $count" "Review externally reachable services and close unused ports"
  else record WARN listeners "ss command unavailable" "Install iproute2"; fi
}

check_kernel(){
  local p
  for p in net.ipv4.ip_forward net.ipv4.conf.all.accept_redirects net.ipv4.conf.all.send_redirects; do
    local v; v="$(sysctl -n "$p" 2>/dev/null || echo unknown)"
    case "$p:$v" in
      net.ipv4.ip_forward:0) record PASS kernel_forward "$p=$v";;
      net.ipv4.ip_forward:1) record WARN kernel_forward "$p=$v" "Disable forwarding unless this host is intentionally a router";;
      net.ipv4.conf.all.accept_redirects:0) record PASS kernel_redirect "$p=$v";;
      net.ipv4.conf.all.send_redirects:0) record PASS kernel_send_redirect "$p=$v";;
      *) record WARN kernel "$p=$v" "Review network hardening policy";;
    esac
  done
}

check_intrusion(){
  if has fail2ban-client && fail2ban-client ping >/dev/null 2>&1; then record PASS fail2ban "Fail2ban is responding"; else record WARN fail2ban "Fail2ban is not detected/responding" "Use Fail2ban or CrowdSec when appropriate"; fi
}

check_docker(){
  if ! has docker; then record PASS docker "Docker not installed; container checks not applicable"; return; fi
  if [[ -S /var/run/docker.sock ]]; then record WARN docker_socket "Docker socket exists at /var/run/docker.sock" "Avoid exposing the Docker socket to untrusted users/containers"; else record PASS docker_socket "Docker socket not found at default path"; fi
  if docker info >/dev/null 2>&1; then record PASS docker_daemon "Docker daemon is reachable"; else record WARN docker_daemon "Docker installed but daemon is not reachable"; fi
}

check_files(){
  local suid=0 ww=0
  if has find; then suid="$(find / -xdev -type f -perm -4000 2>/dev/null | wc -l || true)"; ww="$(find / -xdev -type f -perm -0002 2>/dev/null | wc -l || true)"; fi
  [[ "$suid" -lt 80 ]] && record PASS suid "SUID file count: $suid" || record WARN suid "High SUID file count: $suid" "Review unexpected privileged binaries"
  [[ "$ww" -lt 100 ]] && record PASS writable "World-writable file count: $ww" || record WARN writable "Many world-writable files: $ww" "Review writable paths and ownership"
}

check_updates(){
  if has apt; then
    local n; n="$(apt list --upgradable 2>/dev/null | tail -n +2 | wc -l || true)"; [[ "$n" -eq 0 ]] && record PASS updates "No pending APT upgrades detected" || record WARN updates "$n APT upgrades available" "Apply security updates during a maintenance window"
  elif has dnf; then
    dnf check-update >/dev/null 2>&1; case $? in 0) record PASS updates "No DNF updates detected";; 100) record WARN updates "DNF updates are available" "Apply security updates";; *) record WARN updates "Could not determine DNF update state";; esac
  else record INFO updates "Package manager not recognized" "Review updates using the host distribution's package manager"; fi
}

run_audit(){
  local json="${1:-0}" out="${2:-/tmp/vps-shield-reports}"; mkdir -p "$out" 2>/dev/null || true
  score=100; pass_count=0; fail_count=0; warn_count=0; RESULTS=()
  check_ssh; check_firewall; check_services; check_kernel; check_intrusion; check_docker; check_files; check_updates
  (( score < 0 )) && score=0
  local stamp; stamp="$(date -u +%Y%m%dT%H%M%SZ)"; local report="$out/audit-$stamp"
  if [[ "$json" -eq 1 ]]; then
    printf '{"version":"0.2.0","timestamp":"%s","score":%s,"pass":%s,"warn":%s,"fail":%s,"results":[' "$(date -u +%FT%TZ)" "$score" "$pass_count" "$warn_count" "$fail_count"
    local first=1 r sev id msg rem; for r in "${RESULTS[@]}"; do IFS='|' read -r sev id msg rem <<<"$r"; [[ $first -eq 0 ]] && printf ','; first=0; printf '{"severity":"%s","id":"%s","message":"%s","remediation":"%s"}' "$(printf '%s' "$sev" | sed 's/"/\\"/g')" "$(printf '%s' "$id" | sed 's/"/\\"/g')" "$(printf '%s' "$msg" | sed 's/"/\\"/g')" "$(printf '%s' "$rem" | sed 's/"/\\"/g')"; done
    printf ']}\n' | tee "$report.json"
  else
    printf '\nVPS Shield 0.2.0 — score %s/100\n' "$score" | tee "$report.txt"
    local r sev id msg rem; for r in "${RESULTS[@]}"; do IFS='|' read -r sev id msg rem <<<"$r"; printf '[%-4s] %-24s %s\n' "$sev" "$id" "$msg" | tee -a "$report.txt"; [[ -n "$rem" ]] && printf '      ↳ %s\n' "$rem" | tee -a "$report.txt"; done
    printf '\nPASS=%s WARN=%s FAIL=%s\nReport: %s.txt\n' "$pass_count" "$warn_count" "$fail_count" "$report"
  fi
  return 0
}
