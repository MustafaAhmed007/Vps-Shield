#!/usr/bin/env bash
set -Eeuo pipefail
PREFIX="${PREFIX:-/usr/local/lib/vps-shield}"
BIN="${BIN:-/usr/local/bin/vps-shield}"
ROOT="$(cd "$(dirname "$0")" && pwd)"
[[ $EUID -eq 0 ]] || { echo "Run with sudo: sudo bash install.sh" >&2; exit 1; }
mkdir -p "$PREFIX"
cp -a "$ROOT/scripts" "$ROOT/modules" "$ROOT/policies" "$ROOT/config" "$PREFIX/"
chmod 0755 "$PREFIX/scripts/shield.sh"
chmod 0644 "$PREFIX"/modules/*.sh "$PREFIX"/policies/* "$PREFIX"/config/*
cat >"$BIN" <<EOF
#!/usr/bin/env bash
exec "$PREFIX/scripts/shield.sh" "\$@"
EOF
chmod 0755 "$BIN"
mkdir -p /var/lib/vps-shield/reports /var/lib/vps-shield/backups
chmod 0750 /var/lib/vps-shield /var/lib/vps-shield/reports /var/lib/vps-shield/backups
echo "Installed: $BIN"
