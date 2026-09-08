# SIA CORE Ω — Portfolio Alignment

## Purpose

VPS Shield is a security/infrastructure domain implementation of the portfolio-wide SIA CORE Ω operating architecture:

**objective → observe/research → evidence → strategy/policy → plan → bounded execution → verification → outcome → learning → next decision**

## Universal contract

| Capability | Status | Domain implementation |
|---|---|---|
| Objective / outcome contract | Implemented | Security baseline, posture score and remediation goals |
| Evidence + provenance | Implemented | Host collectors, findings and JSON reports |
| Multi-aspect research | Implemented | Threat model, configuration, vulnerabilities, deployment, recovery, verification |
| Deterministic core | Implemented | Shell checks, policies, dry-run, backup and validation |
| Intelligence/provider boundary | Optional | Research provider boundary; keep AI outside mutation authority |
| Economic routing | Optional | Useful for fleet/hosted operations, not host safety core |
| Orchestration | Implemented | discover/audit/research/plan/harden/verify/monitor/learn |
| Verification/release gates | Implemented | Configuration validation and post-change verification |
| Security/adversarial lane | Implemented | Threat model and defensive security checks; expand adversarial corpus |
| Runtime verification | Implemented | Actual host observation and post-mutation verification |
| Telemetry | Partial | Reports/history; standardize reusable event contract |
| Benchmarking | Partial | Regression/smoke tests; add multidimensional posture benchmarks |
| Experimentation | Optional | Controlled hardening experiments only with rollback |
| Outcome measurement | Partial | Security posture outcomes; add fleet/reliability measures |
| Causal learning | Planned | Controlled remediation → outcome measurements |
| Genome / failure memory | Partial | Failure/regression/documentation loop; normalize reusable rules |
| One-click bootstrap / doctor | Implemented | Installer and environment doctor |
| Artifact evidence trail | Implemented | Reports, backups and research bundles |
| Adapter boundaries | Implemented | Docker, Coolify, CrowdSec, Fail2ban, Trivy, Falco, Wazuh, Cloudflare/systemd |

## Domain boundary

Infrastructure-specific capabilities remain local: Linux host collection, SSH/firewall/network posture, systemd, Docker, hardening, backup/rollback and recurring drift audits.

## Non-negotiables

1. Audit before mutation.
2. Dry-run before apply.
3. Backup before risky changes.
4. Validate before reload.
5. Verify actual state after mutation.
6. Keep rollback available.
7. Never print secrets.
8. Never silently alter network exposure.

## Target end state

Share generic evidence, research, verification, outcomes, telemetry, benchmarking and learning contracts with SIA CORE Ω while keeping host-security mutation logic domain-specific and fail-safe.
