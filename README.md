# VPS Shield

> **Defensive Linux VPS security toolkit — audit, score, harden, verify, rollback, monitor.**

VPS Shield turns repeatable server-hardening practice into an auditable lifecycle: **discover → audit → score → plan → backup → harden → verify → monitor → learn**.

## Included

- Effective OpenSSH checks using `sshd -T`, including `sshd_config.d`
- Root login, password authentication, X11 and SSH-file permissions
- Firewall detection across UFW, firewalld, nftables and iptables
- Fail2ban/CrowdSec detection
- Listening ports/services and systemd inventory
- Kernel/sysctl network posture
- SUID/SGID and world-writable discovery
- Docker daemon/socket posture
- Package/update posture
- Redacted secret-pattern detection
- Conservative SSH/kernel remediation
- Dry-run, backup, verification and rollback
- Human and JSON evidence
- Baseline policy, tests and CI
- Optional integration probes
- systemd audit service/timer templates

## Quick start

```bash
git clone https://github.com/MustafaAhmed007/Vps-Shield.git
cd Vps-Shield
sudo bash install.sh
sudo vps-shield audit
sudo vps-shield audit --json
sudo vps-shield harden --dry-run
sudo vps-shield harden --apply
sudo vps-shield verify
sudo vps-shield integrations
```

**Important:** `harden` is dry-run by default. `--apply` is required for mutation.

## Architecture

```text
CLI → Policy → Collectors → Checks → Score → Evidence
                         ↓
                    Remediation
                         ↓
                 Backup → Change → Verify
                         ↓
                      Rollback
```

## Defense-in-depth

VPS Shield is the host-security orchestration layer. External products remain explicit adapters:

- CrowdSec / Fail2ban — intrusion prevention
- Trivy — vulnerability + SBOM evidence
- Falco — runtime detection
- Wazuh — SIEM/host monitoring
- Cloudflare Zero Trust — identity-aware access
- Coolify — application-platform posture
- Docker — container isolation/posture
- systemd — recurring evidence collection

No adapter silently installs software, changes DNS, opens ports, or alters authentication.

## Safety model

No hardening tool can guarantee an impenetrable server. Keep out-of-band recovery access, verify a second administrative session, review dry-run output, and test rollback before production. SSH and firewall changes can lock you out.

## Development

```bash
bash -n scripts/shield.sh
bash -n modules/audit.sh
bash -n modules/harden.sh
bash -n modules/integrations.sh
bash tests/test_audit.sh
```

## Monetization

Open-source CLI → adoption → posture evidence → paid fleet monitoring, hosted dashboard/API, compliance exports, managed hardening, enterprise policy management and support.

## Feedback loop

```text
User report → reproduce → regression test → fix → verify → release → document
```

Recurring false positives become tests and policy improvements instead of being hidden.

## License

MIT. See `LICENSE`.
