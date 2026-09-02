# Integration Playbook

VPS Shield uses an adapter model. The host engine remains usable when integrations are absent.

## CrowdSec

Use for collaborative threat detection/blocking. The current project probes `cscli`; installation and firewall integration remain operator-controlled.

## Fail2ban

The audit detects a responding `fail2ban-client`. Keep jails specific to services actually exposed by the host.

## Trivy

Recommended future adapter flow:

```text
Discover images/filesystems → Trivy scan → normalize findings → attach to VPS Shield evidence → trend over time
```

Do not auto-delete images or packages based solely on a scanner result.

## Falco

Recommended future adapter flow:

```text
Kernel/runtime events → Falco → normalize high-confidence events → alert/evidence store
```

Runtime rules must be tuned to workload behavior to control false positives.

## Wazuh

Use for centralized host telemetry, file integrity and alert correlation. VPS Shield should export normalized evidence rather than duplicate the entire SIEM.

## Cloudflare Zero Trust

Use for identity-aware access to administrative/application surfaces. DNS, tunnels and access policies must remain explicit operator configuration.

## Coolify

Scan deployment/platform posture: exposed management ports, privileged containers, Docker socket exposure, secrets handling and TLS/reverse-proxy configuration.

## Principle

Integrations add defense depth; they do not remove the need for backups, least privilege, secure authentication, patching and recovery testing.
