#!/usr/bin/env bash
# Multi-aspect infrastructure/security research. Read-only by design.
set -Eeuo pipefail

research_usage(){
  cat <<'EOF'
VPS Shield research
Usage:
  sudo vps-shield research "topic"
  sudo vps-shield research "topic" --url https://example.com
  sudo vps-shield research "topic" --cloud

Environment:
  VPS_SHIELD_RESEARCH_DIR  Evidence directory (default: /var/lib/vps-shield/research)
  VPS_SHIELD_SEARCH_URL    Optional JSON search endpoint accepting POST {"query":"..."}
  VPS_SHIELD_SEARCH_HEADER Optional HTTP header, e.g. Authorization: Bearer ...

The engine researches multiple angles: threat model, configuration, vulnerabilities,
operational deployment, recovery, and verification. Cloud search is optional. Without
it, direct URLs and local evidence remain usable.
EOF
}

_research_slug(){
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9._-' '-' | sed 's/^-*//;s/-*$//'
}

_research_local(){
  local query="$1" out="$2"
  printf '%s\n' "LOCAL FALLBACK" "Query: $query" "" > "$out"
  printf '%s\n' "Use local repository files, installed documentation, and operator-provided URLs as evidence." >> "$out"
}

_research_cloud(){
  local query="$1" out="$2"
  [[ -n "${VPS_SHIELD_SEARCH_URL:-}" ]] || return 1
  command -v curl >/dev/null 2>&1 || return 1
  local body='{"query":"'"$(printf '%s' "$query" | sed 's/\\/\\\\/g;s/"/\\"/g')"'"}'
  if [[ -n "${VPS_SHIELD_SEARCH_HEADER:-}" ]]; then
    curl -fsSL --max-time 20 -H 'Content-Type: application/json' -H "$VPS_SHIELD_SEARCH_HEADER" \
      -d "$body" "$VPS_SHIELD_SEARCH_URL" > "$out"
  else
    curl -fsSL --max-time 20 -H 'Content-Type: application/json' -d "$body" "$VPS_SHIELD_SEARCH_URL" > "$out"
  fi
}

_research_url(){
  local url="$1" out="$2"
  command -v curl >/dev/null 2>&1 || { echo "curl is required for --url fallback." >&2; return 1; }
  curl -fsSL --max-time 30 -L "$url" -o "$out"
}

run_research(){
  local topic="${1:-}" mode="${2:-auto}" direct_url="${3:-}"
  [[ -n "$topic" ]] || { research_usage; return 2; }
  local dir="${VPS_SHIELD_RESEARCH_DIR:-/var/lib/vps-shield/research}"
  mkdir -p "$dir"
  local slug; slug="$(_research_slug "$topic")"
  local stamp; stamp="$(date -u +%Y%m%dT%H%M%SZ)"
  local run_dir="$dir/${stamp}-${slug}"
  mkdir -p "$run_dir"

  local aspects=("threat-model" "configuration" "vulnerabilities" "deployment" "recovery" "verification")
  local aspect query out status="LOCAL"
  for aspect in "${aspects[@]}"; do
    query="$topic — research aspect: $aspect"
    out="$run_dir/$aspect.txt"
    if [[ "$mode" == "cloud" || ("$mode" == "auto" && -n "${VPS_SHIELD_SEARCH_URL:-}") ]]; then
      if _research_cloud "$query" "$out"; then status="CLOUD"; else _research_local "$query" "$out"; fi
    else
      _research_local "$query" "$out"
    fi
  done

  if [[ -n "$direct_url" ]]; then
    if _research_url "$direct_url" "$run_dir/direct-url.txt"; then
      echo "Direct URL evidence: $run_dir/direct-url.txt"
    else
      echo "Warning: direct URL could not be fetched: $direct_url" >&2
    fi
  fi

  cat > "$run_dir/manifest.json" <<EOF
{
  "topic": "$(printf '%s' "$topic" | sed 's/\\/\\\\/g;s/"/\\"/g')",
  "timestamp_utc": "$stamp",
  "mode": "$status",
  "aspects": ["threat-model", "configuration", "vulnerabilities", "deployment", "recovery", "verification"],
  "direct_url": "$(printf '%s' "$direct_url" | sed 's/\\/\\\\/g;s/"/\\"/g')"
}
EOF
  echo "Research evidence: $run_dir"
}
