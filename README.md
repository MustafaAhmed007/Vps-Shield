# VPS Shield

> Defensive Linux VPS security toolkit — audit, score, harden, verify, rollback, monitor.

VPS Shield turns repeatable server-hardening practice into an auditable lifecycle: **discover → audit → score → plan → backup → harden → verify → monitor → learn**.

## Included

- Effective OpenSSH checks using `sshd -T` when available, including `sshd_config.d`
- Root login, password authentication, protocol and sensitive SSH-file permissions
- Firewall detection across UFW, firewalld, nftables and iptables
- Fail2ban posture
- Listening ports/services and systemd inventory
- Kernel/sysctl network hardening checks
- IP forwarding and redirect checks
- SUID/SGID and world-writable discovery
- Docker daemon/socket/container posture
- Package/update/reboot posture
- Redacted secret-pattern detection
- Conservative SSH, firewall and kernel remediation
- Dry-run, backup, verification and rollback
- Human and JSON reports
- Baseline policy
- CI, regression tests, security/threat-model documentation

## Quick start

```bash
git clone https://github.com/MustafaAhmed007/Vps-Shield.git
cd Vps-Shield
sudo ./scripts/shield.sh audit
sudo ./scripts/shield.sh audit --json
sudo ./scripts/shield.sh harden --dry-run
sudo ./scripts/shield.sh harden
sudo ./scripts/shield.sh verify
```

## Architecture

```text
CLI → Policy → Collectors → Checks → Score → Report
                     ↓
                Remediation
                     ↓
             Backup → Change → Verify
                     ↓
                  Rollback
```

## Defense-in-depth roadmap

CrowdSec, Falco, Wazuh, Trivy/SBOM, Cloudflare Zero Trust, Coolify posture scanning, systemd scheduling, fleet management and a hosted dashboard are designed as explicit adapters. VPS Shield never silently installs or enables third-party services.

## Safety

No hardening tool can guarantee an impenetrable server. Keep out-of-band recovery access, review dry-run output, and test changes before production. SSH/firewall changes can lock you out.

## Development

```bash
bash -n scripts/shield.sh
bash -n modules/audit.sh
bash -n modules/harden.sh
bash tests/test_audit.sh
```

## Monetization

Open-source CLI → adoption → posture evidence → paid fleet monitoring, hosted dashboard/API, compliance exports, managed hardening, enterprise policy management and support.

## Feedback loop

User report → reproduce → regression test → fix → verify → release → document.

## License

MIT. See LICENSE.
