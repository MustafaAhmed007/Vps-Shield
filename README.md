# VPS Shield

> **Defensive Linux VPS security toolkit for developers, self-hosters and small infrastructure teams — audit, research, score, harden, verify, rollback and continuously improve server security.**

VPS Shield turns scattered VPS-security work into a repeatable, evidence-driven operating system:

**discover → research → audit → score → explain → plan → backup → harden → verify → monitor → learn**

It is built for modern developer infrastructure: Linux VPSs running Docker, AI workloads, automation, SaaS applications, reverse proxies, databases, CI/CD agents and platforms such as Coolify.

The goal is not another dashboard or another pile of shell commands. The goal is to make infrastructure security **simpler to deploy, easier to understand, safer to change, easier to verify and continuously improvable**.

---

## Why VPS Shield exists

A VPS can become the foundation of an entire product. One machine may host applications, Docker, databases, reverse proxies, automation, AI services, CI/CD and secrets.

Security is too often managed through scattered commands, copied blog-post checklists and undocumented operator knowledge. VPS Shield turns that into an executable lifecycle.

| Without VPS Shield | With VPS Shield |
|---|---|
| Manual security checklist | Repeatable security lifecycle |
| Guessing what is exposed | Evidence from the running host |
| Searching randomly after a finding | Multi-aspect research with evidence fallbacks |
| Copy/paste hardening | Dry-run → backup → change → verify |
| Risky SSH changes | Validation + rollback path |
| Security knowledge in someone's head | Versioned policy + tests + documentation |
| Different servers configured differently | Consistent baseline |
| “I think it is secure” | Measurable posture + evidence |
| Security after an incident | Security as a recurring loop |
| Days/weeks spent debugging setup | One installation path + environment doctor |
| Tool sprawl | Explicit adapter boundaries |

VPS Shield does **not** promise an impenetrable server. It provides a disciplined control layer for reducing common configuration and operational risk while keeping security work understandable and reversible.

---

# System architecture

```text
                         VPS SHIELD
┌──────────────────────────────────────────────────────────────┐
│                         OPERATOR                             │
│              CLI • CI/CD • provisioning • systemd           │
└────────────────────────────┬─────────────────────────────────┘
                             ↓
┌──────────────────────────────────────────────────────────────┐
│                    ORCHESTRATION LAYER                       │
│   doctor • research • audit • score • plan • harden • verify │
└───────────────┬───────────────────────┬──────────────────────┘
                ↓                       ↓
┌────────────────────────┐   ┌─────────────────────────────────┐
│   EVIDENCE / RESEARCH  │   │       SECURITY ENGINE            │
│ cloud search (optional)│   │ collectors → checks → findings  │
│ local fallback         │   │ policy → score → remediation    │
│ direct URL evidence    │   │ backup → validate → verify      │
└────────────┬───────────┘   └────────────────┬────────────────┘
             └────────────────┬───────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────┐
│                 INTEGRATION / ADAPTER LAYER                  │
│ Docker • Coolify • CrowdSec • Fail2ban • Trivy • Falco       │
│ Wazuh • Cloudflare • systemd                                 │
└────────────────────────────┬─────────────────────────────────┘
                             ↓
┌──────────────────────────────────────────────────────────────┐
│                         LINUX VPS                            │
│ SSH • firewall • services • packages • kernel • containers   │
│ permissions • processes • application/runtime environment    │
└──────────────────────────────────────────────────────────────┘
```

The architecture deliberately separates **observation, research, policy, mutation, integrations and verification**. That keeps the core small while allowing the system to grow into deeper security automation and fleet capabilities.

---

# Core security lifecycle

```text
DISCOVER
   ↓
AUDIT ───────────────→ collect host evidence without mutation
   ↓
SCORE + EXPLAIN ─────→ identify risk and next action
   ↓
RESEARCH ────────────→ investigate multiple relevant aspects
   ↓
PLAN
   ↓
DRY-RUN ─────────────→ preview intended mutations
   ↓
BACKUP
   ↓
APPLY ───────────────→ controlled remediation
   ↓
VALIDATE ────────────→ reject unsafe configuration
   ↓
VERIFY ──────────────→ prove intended state
   ↓
MONITOR ─────────────→ detect drift
   ↓
LEARN ───────────────→ improve tests, policy and remediation
   └──────────────────────────────→ next audit
```

**Security is a loop, not a one-time setup script.**

---

# Repository architecture

```text
Vps-Shield/
├── .github/workflows/
│   └── security.yml              # CI, syntax, regression and secret scanning
├── config/
│   └── security.env.example      # Optional operator configuration
├── docs/
│   ├── architecture.md           # System design and boundaries
│   ├── deployment.md             # Deployment runbook
│   ├── hardening.md              # Hardening procedure
│   ├── integrations.md           # Adapter playbook
│   ├── one-click.md              # Installation/environment contract
│   ├── research.md               # Multi-aspect research architecture
│   ├── roadmap.md                # Evolution path
│   └── threat-model.md            # Threats and trust boundaries
├── integrations/
│   └── README.md                 # Adapter conventions
├── modules/
│   ├── audit.sh                  # Read-only host checks
│   ├── harden.sh                 # Controlled remediation
│   ├── integrations.sh           # Integration probes
│   └── research.sh               # Multi-aspect evidence/research engine
├── policies/
│   └── baseline.yaml             # Versioned security baseline
├── scripts/
│   └── shield.sh                 # Main CLI
├── systemd/
│   ├── vps-shield-audit.service  # Audit service template
│   └── vps-shield-audit.timer    # Recurring schedule
├── tests/
│   └── test_audit.sh             # Regression/smoke tests
├── install.sh                    # One-click installer + self-check
├── Makefile                      # Developer shortcuts
├── SECURITY.md
├── CONTRIBUTING.md
├── CHANGELOG.md
└── LICENSE
```

### Design boundaries

- **CLI:** thin operator interface.
- **Doctor:** verifies the environment contract before operation.
- **Research:** gathers contextual evidence without executing external instructions.
- **Audit:** observes and evaluates; it should remain read-only.
- **Policy:** defines the desired security state independently of collection.
- **Hardening:** performs explicit, controlled mutations.
- **Integrations:** provide optional capabilities without becoming hidden dependencies.
- **Tests/CI:** convert security behavior into a regression-controlled asset.

---

# One-click installation

The installation experience is a first-class part of the architecture. Users should not need to spend days or weeks resolving setup problems before reaching the useful part of the product.

From a checkout:

```bash
sudo bash install.sh
```

The installer:

1. checks root privileges and required local commands;
2. installs the runtime under `/usr/local/lib/vps-shield`;
3. creates the `vps-shield` command;
4. creates protected report, backup and research directories;
5. runs a version check;
6. runs the environment doctor;
7. stops with an actionable failure if a required baseline capability is missing.

Optional capabilities are detected rather than silently installing arbitrary software.

Then:

```bash
sudo vps-shield doctor
sudo vps-shield audit
```

### Why this matters

The installation path becomes reusable infrastructure for future provisioning, CI/CD images, cloud-init, Ansible/Terraform adapters and fleet onboarding instead of another manual setup guide.

One-click means **one entry point with a predictable contract**, not uncontrolled mutation of the host.

See `docs/one-click.md` for the environment contract.

---

# Multi-aspect auto-research

Security findings frequently need context. VPS Shield therefore includes a provider-neutral research layer.

For a topic, it investigates multiple angles:

```text
Finding / question
       ↓
┌───────────────────────────────┐
│ Threat model                  │
│ Configuration                 │
│ Vulnerabilities               │
│ Deployment                    │
│ Recovery                      │
│ Verification                  │
└───────────────┬───────────────┘
                ↓
     Optional cloud search
                ↓
       Local evidence fallback
                ↓
        Direct URL evidence
                ↓
     Persistent research bundle
```

Examples:

```bash
sudo vps-shield research "Docker socket security"
sudo vps-shield research "OpenSSH hardening" --cloud
sudo vps-shield research "Coolify VPS exposure" --url https://example.com/security-guide
```

Cloud search is optional and configured through `VPS_SHIELD_SEARCH_URL` and an optional `VPS_SHIELD_SEARCH_HEADER`. Without cloud credentials, the system remains usable with local evidence and operator-selected direct URLs.

Research is **read-only**. External content is treated as evidence to review, never as instructions to execute.

See `docs/research.md` for the provider/fallback model.

---

# What VPS Shield audits

The current audit engine covers practical VPS security signals including:

- effective OpenSSH configuration via `sshd -T`, including drop-ins;
- root login and password authentication posture;
- X11 forwarding;
- SSH configuration/file permissions;
- UFW, firewalld, nftables and iptables detection;
- listening sockets and service exposure;
- systemd/service inventory signals;
- kernel/sysctl network posture;
- IPv4 redirects and source routing;
- Fail2ban/CrowdSec availability;
- Docker daemon/socket posture;
- SUID/SGID discovery;
- world-writable file discovery;
- package/update posture;
- redacted secret-pattern detection;
- human-readable reports;
- JSON evidence for automation.

The audit answers:

1. **What is exposed or misconfigured?**
2. **How serious is it relative to the baseline?**
3. **What should be investigated or changed next?**

---

# Hardening path

Hardening is deliberately separated from auditing.

```text
AUDIT
  ↓
REVIEW FINDINGS
  ↓
DRY-RUN
  ↓
REVIEW MUTATIONS
  ↓
BACKUP
  ↓
APPLY
  ↓
VALIDATE CONFIGURATION
  ↓
RELOAD / APPLY SAFELY
  ↓
VERIFY ACTUAL STATE
  ↓
KEEP OR ROLLBACK
```

Current conservative remediation includes:

- `PermitRootLogin no`
- `PasswordAuthentication no`
- `X11Forwarding no`
- conservative network redirect/source-route sysctl settings

SSH configuration is syntax-validated before reload. Backups are created before supported mutation and rollback is available.

Firewall automation remains conservative because an incorrect remote firewall change can cause immediate lockout. VPS Shield detects and reports firewall posture rather than blindly rewriting network access.

---

# Defense in depth

VPS Shield is the **host posture/orchestration layer**, not a claim that one tool replaces the entire security stack.

```text
APPLICATION / DATA
        ↓
PLATFORM / CONTAINERS
 Docker • Coolify • reverse proxy
        ↓
RUNTIME DEFENSE
 Falco • runtime behavior
        ↓
INTRUSION / HOST MONITORING
 CrowdSec • Fail2ban • Wazuh
        ↓
ACCESS / EDGE
 SSH • firewall • Cloudflare
        ↓
HOST BASELINE
 Linux • sysctl • packages • permissions • services
        ↓
VPS SHIELD CONTROL LOOP
 discover → audit → remediate → verify → learn
```

Optional/adapter targets include Docker, Coolify, CrowdSec, Fail2ban, Trivy, Falco, Wazuh, Cloudflare Zero Trust/Tunnel and systemd.

The adapter boundary is intentional: an adapter must not silently install software, modify DNS, open ports or change authentication merely because it is available.

---

# The security feedback loop

```text
Real server
   ↓
Evidence
   ↓
Finding
   ↓
Research / context
   ↓
Remediation
   ↓
Verification
   ↓
Historical evidence
   ↓
Drift / failure / false positive
   ↓
Regression test
   ↓
Policy/check improvement
   ↓
Release
   └────────────────→ better future audits
```

This is the compounding asset of the project:

**production problem → reproducible case → test → better check/policy → safer remediation → stronger future system.**

---

# How it benefits development

### Faster bring-up
One audit replaces a large portion of manual security inspection.

### Safer changes
Dry-run, backup, validation, verification and rollback reduce operational risk.

### Less context switching
SSH, firewall, services, kernel, packages and Docker posture become one workflow.

### Repeatable environments
The same baseline can be evaluated across development, staging and production.

### Easier debugging
Evidence helps separate application problems from host, network, SSH, firewall or runtime problems.

### Automation-ready
JSON evidence and stable CLI contracts create a path to CI/CD gates, APIs, dashboards and fleet management.

---

# How it benefits deployment and hosting

```text
Provision VPS
    ↓
Install OS/runtime
    ↓
Install VPS Shield
    ↓
Doctor
    ↓
Audit
    ↓
Research when needed
    ↓
Dry-run
    ↓
Apply approved hardening
    ↓
Deploy application
    ↓
Verify
    ↓
Recurring audit
    ↓
Detect drift
    ↓
Remediate / rollback / learn
```

This moves security from a last-minute manual task into the normal deployment lifecycle.

For Docker/Coolify/Cloudflare-based infrastructure, VPS Shield provides a common host posture layer while specialized systems retain their own responsibilities.

---

# CLI

| Command | Purpose | Host mutation |
|---|---|---:|
| `doctor` | Check environment contract | No |
| `audit` | Collect/evaluate posture | No |
| `audit --json` | Machine-readable evidence | No |
| `research <topic>` | Multi-aspect research | No |
| `research <topic> --cloud` | Use configured cloud search | No |
| `research <topic> --url URL` | Add direct URL evidence | No |
| `harden --dry-run` | Preview remediation | No |
| `harden --apply` | Apply approved remediation | Yes |
| `verify` | Re-evaluate state | No |
| `integrations` | Probe integrations | No |
| `rollback <backup-dir>` | Restore supported backup | Yes |
| `version` | Show version | No |

`harden` is dry-run by default. `--apply` is required for mutation.

---

# Recurring monitoring

The repository provides systemd service/timer templates:

```text
systemd timer
      ↓
VPS Shield audit
      ↓
JSON evidence
      ↓
local reports/history
      ↓
future alerting/dashboard/API
```

The lightweight local-first model avoids requiring a heavyweight control plane for a single VPS.

---

# Engineering quality and safety

Current safeguards include:

- Bash syntax checks;
- audit smoke/regression tests;
- GitHub Actions CI;
- secret scanning with Gitleaks;
- versioned baseline policy;
- threat model and security policy;
- dry-run-first remediation;
- configuration validation before SSH reload;
- backup and rollback support;
- recurring audit templates.

Non-negotiable rules:

- audit before mutation;
- dry-run before apply;
- backup before risky configuration changes;
- validate before reload;
- verify after mutation;
- keep rollback available;
- do not print detected secrets;
- do not silently alter network exposure;
- do not pretend a score proves security;
- treat external integrations as explicit trust boundaries.

Always maintain a second administrative session or out-of-band recovery path before changing remote access.

---

# Roadmap

### Phase 1 — Host baseline

Audit, scoring, evidence, conservative hardening, verification, rollback, policy and recurring audits.

### Phase 2 — Defense adapters

Deeper Docker posture, CrowdSec/Fail2ban controls, Trivy vulnerability/SBOM evidence, Falco runtime signals, Wazuh telemetry, Cloudflare posture and Coolify checks.

### Phase 3 — Security evidence platform

Normalized findings, historical reports, drift detection, evidence retention, remediation plans, policy profiles and signed/exportable evidence.

### Phase 4 — Fleet control plane

Multi-VPS inventory, centralized dashboard/API, RBAC, fleet-wide policy, alerting, deployment integration and tenant isolation.

### Phase 5 — Self-improving security system

False-positive analysis, regression corpus, recommendation-quality measurement, remediation success rates, environment-aware policy and evidence correlation.

The objective is a **compounding security operating layer for developer infrastructure**, not another generic dashboard.

---

# Product flywheel

```text
Open source
    ↓
Developer adoption
    ↓
Real VPS evidence
    ↓
Trust + recurring usage
    ↓
Fleet / hosted needs
    ↓
Monitoring + dashboard/API
    ↓
Compliance/evidence
    ↓
Managed hardening/support
    ↓
Enterprise policy/fleet controls
    └────────────→ more deployments + more learning
```

Potential revenue layers include managed hardening, fleet monitoring, hosted dashboard/API, compliance evidence, premium integrations, enterprise policy and support.

---

# Contributing

Prefer improvements that strengthen the loop:

```text
Problem → reproduce → evidence → minimal fix → regression test → verify → document
```

A repeated production issue or false positive should become a test so the system gets harder to break over time.

See `CONTRIBUTING.md` and `SECURITY.md`.

---

# License

MIT. See `LICENSE`.
