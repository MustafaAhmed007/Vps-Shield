# Threat Model

## Assets

- SSH access and credentials
- Application secrets and environment variables
- Customer/application data
- Docker workloads and images
- Host integrity and availability
- Security evidence/reports

## Adversaries

- Internet-wide scanners and credential attackers
- Opportunistic malware/botnets
- A compromised application/container attempting host escape
- A low-privilege local account attempting privilege escalation
- Supply-chain or vulnerable-package attackers

## Defenses

| Threat | Primary control |
|---|---|
| SSH brute force | key-based auth, password disablement, Fail2ban/CrowdSec |
| Exposed services | listener inventory + firewall policy |
| Kernel/network abuse | sysctl baseline |
| Container-to-host abuse | Docker socket and privilege checks |
| Privilege escalation | SUID/SGID and writable-path inventory |
| Vulnerable software | package updates + future Trivy adapter |
| Persistence | future integrity/runtime adapters |
| Credential leakage | redacted secret-pattern detection |

## Non-goals

VPS Shield does not replace application security, provider-level DDoS protection, a full SIEM, EDR, vulnerability management, backups, or incident-response expertise.

## Security invariant

A remediation must never be treated as successful until the intended control is verified. If verification fails, the system should preserve evidence and prefer rollback over silently continuing.
