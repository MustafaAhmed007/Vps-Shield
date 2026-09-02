# VPS Shield

> **Defensive Linux VPS security toolkit for developers, self-hosters and small infrastructure teams — audit, score, harden, verify, rollback and continuously improve server security.**

VPS Shield turns scattered VPS-security tasks into a repeatable, evidence-driven operating loop:

**discover → audit → score → explain → plan → backup → harden → verify → monitor → learn**

It is designed for the reality of modern developer infrastructure: Linux VPSs running Docker, AI workloads, automation, SaaS applications, reverse proxies, databases, CI/CD agents and platforms such as Coolify. The goal is not to add another dashboard that hides complexity. The goal is to make the security work around your server **simpler, safer, inspectable and repeatable**.

---

## Why VPS Shield exists

A VPS often becomes the foundation for an entire product. One machine may host the application, Docker runtime, database, reverse proxy, automation workers, AI services, CI/CD and secrets.

That creates a practical problem: security is usually handled as a collection of one-off commands and blog-post checklists.

VPS Shield converts that into an operating model:

| Without VPS Shield | With VPS Shield |
|---|---|
| Manual security checklist | Repeatable audit lifecycle |
| Guessing what is exposed | Evidence from the running host |
| Hardening by copy/paste | Dry-run → backup → change → verify |
| Risky SSH changes | Syntax validation + rollback path |
| Security knowledge in someone's head | Versioned policy + documented checks |
| Different servers configured differently | Consistent baseline |
| “I think it is secure” | Measurable posture + evidence |
| Security after an incident | Security as a recurring loop |
| Tool sprawl | Explicit integration/adaptor boundary |

VPS Shield does **not** promise an impenetrable server. It provides a disciplined control layer for reducing common configuration and operational risk while keeping changes understandable and reversible.

---

## Core lifecycle

```text
                    ┌──────────────────────┐
                    │      DISCOVER        │
                    │ OS / services / SSH  │
                    │ firewall / Docker    │
                    └──────────┬───────────┘
                               ↓
                    ┌──────────────────────┐
                    │        AUDIT         │
                    │ Collect host evidence│
                    │ without changing it  │
                    └──────────┬───────────┘
                               ↓
                    ┌──────────────────────┐
                    │    SCORE + EXPLAIN   │
                    │ PASS / WARN / FAIL   │
                    │ + actionable context │
                    └──────────┬───────────┘
                               ↓
                    ┌──────────────────────┐
                    │ PLAN + DRY-RUN       │
                    │ Decide what should    │
                    │ actually change       │
                    └──────────┬───────────┘
                               ↓
                    ┌──────────────────────┐
                    │ BACKUP + HARDEN      │
                    │ Controlled mutation  │
                    └──────────┬───────────┘
                               ↓
                    ┌──────────────────────┐
                    │ VERIFY               │
                    │ Prove intended state │
                    │ after the change     │
                    └──────────┬───────────┘
                               ↓
                    ┌──────────────────────┐
                    │ MONITOR              │
                    │ Recurring evidence   │
                    └──────────┬───────────┘
                               ↓
                    ┌──────────────────────┐
                    │ LEARN                │
                    │ Tests / policy /     │
                    │ remediation improve │
                    └──────────┬───────────┘
                               │
                               └───────────→ next audit
```

The important design choice is that **security is a loop, not a one-time setup script**.

---

# Repository architecture

The repository is intentionally modular so the security engine can evolve without turning the CLI into a monolith.

```text
Vps-Shield/
├── .github/
│   └── workflows/
│       └── security.yml          # CI: syntax, regression tests, secret scanning
│
├── config/
│   └── security.env.example      # Optional operator configuration template
│
├── docs/
│   ├── architecture.md           # System architecture and design boundaries
│   ├── deployment.md             # Installation and deployment runbook
│   ├── hardening.md              # Hardening procedure and safety guidance
│   ├── integrations.md           # Integration/adaptor playbook
│   ├── roadmap.md                # Evolution toward fleet/platform capabilities
│   └── threat-model.md            # Threats, assumptions and trust boundaries
│
├── integrations/
│   └── README.md                 # Integration layer conventions
│
├── modules/
│   ├── audit.sh                  # Read-only host collectors and security checks
│   ├── harden.sh                 # Controlled remediation + backup/rollback
│   └── integrations.sh           # Read-only integration capability probes
│
├── policies/
│   └── baseline.yaml             # Versioned conservative VPS security baseline
│
├── scripts/
│   └── shield.sh                 # Main CLI entry point
│
├── systemd/
│   ├── vps-shield-audit.service  # Recurring audit service template
│   └── vps-shield-audit.timer    # Scheduled evidence collection
│
├── tests/
│   └── test_audit.sh             # Shell syntax + audit smoke/regression tests
│
├── install.sh                    # Installer + CLI wrapper setup
├── Makefile                      # Developer shortcuts
├── SECURITY.md                   # Vulnerability reporting and security policy
├── CONTRIBUTING.md               # Contribution workflow
├── CHANGELOG.md                  # Version history
└── LICENSE                       # MIT license
```

### Module boundaries

**CLI** is the operator interface. It should stay thin.

**Audit** is responsible for collecting evidence and evaluating the current host posture without mutating the system.

**Policy** defines what “good” looks like. This is intentionally separated from the collection engine so future policy profiles can evolve independently.

**Hardening** contains controlled mutations. It is intentionally conservative and requires explicit `--apply` for changes.

**Integrations** detect whether external security/control-plane capabilities are available. They are adapters, not hidden dependencies.

**Tests + CI** turn security behavior into a regression-controlled asset rather than a collection of undocumented assumptions.

---

# What VPS Shield audits today

The current audit engine covers practical VPS security signals including:

- Effective OpenSSH configuration using `sshd -T`, including drop-in configuration
- Root login posture
- Password authentication posture
- X11 forwarding
- SSH configuration/file permissions
- Firewall presence across UFW, firewalld, nftables and iptables
- Listening sockets and service exposure
- systemd/service inventory signals
- Kernel/sysctl network posture
- IPv4 redirects and source-routing posture
- Fail2ban and CrowdSec availability
- Docker daemon/socket posture
- SUID/SGID discovery
- World-writable file discovery
- Package/update posture for common Linux package managers
- Redacted secret-pattern detection in relevant system/application locations
- Human-readable reports
- JSON evidence for automation and future APIs

The audit is designed to answer three practical questions:

1. **What is exposed or misconfigured?**
2. **How serious is it relative to the baseline?**
3. **What should the operator investigate or change next?**

---

# Hardening path

Hardening is deliberately separated from auditing. A server should be able to be inspected without being changed.

```text
AUDIT
  ↓
Review findings
  ↓
DRY-RUN
  ↓
Review intended mutations
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

### Current conservative remediation

VPS Shield can safely target selected high-value baseline changes such as:

- `PermitRootLogin no`
- `PasswordAuthentication no`
- `X11Forwarding no`
- conservative network redirect/source-route sysctl settings

Before SSH changes are reloaded, configuration syntax is validated. A backup is created before mutation, and rollback is available.

### Why firewall changes are treated differently

Automatically enabling or rewriting a firewall is intentionally conservative because an incorrect rule can immediately disconnect a remote operator.

VPS Shield therefore **detects and reports firewall posture rather than blindly opening/closing ports**. Future policy-aware firewall automation should require explicit intent, service discovery, allow-list validation and a recovery path.

---

# Defense in depth

VPS Shield is not intended to replace every security product. It acts as the **orchestration and posture layer around the host**, while specialized tools provide additional controls.

```text
┌──────────────────────────────────────────────────────────────┐
│                    APPLICATION / DATA                        │
│  SaaS • AI • APIs • databases • automation • secrets         │
├──────────────────────────────────────────────────────────────┤
│                 PLATFORM / CONTAINER LAYER                   │
│  Docker • Coolify • reverse proxy • service isolation        │
├──────────────────────────────────────────────────────────────┤
│                    RUNTIME DEFENSE                            │
│  Falco • process/runtime signals • container behavior        │
├──────────────────────────────────────────────────────────────┤
│                INTRUSION / HOST MONITORING                   │
│  CrowdSec • Fail2ban • Wazuh                                 │
├──────────────────────────────────────────────────────────────┤
│                  ACCESS / EDGE CONTROL                        │
│  SSH • firewall • Cloudflare Zero Trust / Tunnel             │
├──────────────────────────────────────────────────────────────┤
│                     HOST BASELINE                            │
│  Linux • sysctl • packages • permissions • services           │
├──────────────────────────────────────────────────────────────┤
│                      VPS SHIELD                              │
│  discover → audit → score → remediate → verify → learn       │
└──────────────────────────────────────────────────────────────┘
```

### Integration philosophy

Planned/optional integrations include:

| Layer | Integration | Role |
|---|---|---|
| Access/edge | Cloudflare Zero Trust / Tunnel | Reduce direct exposure and centralize access controls |
| Platform | Coolify | Application/control-plane posture awareness |
| Containers | Docker | Isolation and container configuration evidence |
| Intrusion prevention | CrowdSec / Fail2ban | Detect/block abusive authentication and traffic patterns |
| Runtime | Falco | Runtime behavior and syscall-based detection |
| Vulnerability | Trivy | Image/filesystem vulnerability and SBOM evidence |
| Host/SIEM | Wazuh | Host telemetry, monitoring and security events |
| Scheduling | systemd | Recurring audits and evidence collection |

These integrations remain explicit. VPS Shield should never silently install a third-party security product, modify DNS, expose a port or change authentication policy merely because an adapter exists.

---

# The security loop

The long-term advantage is not a single hardening run. It is the **feedback loop**.

```text
┌──────────────┐
│ Real server  │
└──────┬───────┘
       ↓
   Collect evidence
       ↓
   Detect deviation
       ↓
   Score + explain
       ↓
   Remediate safely
       ↓
   Verify outcome
       ↓
   Store evidence
       ↓
   Observe over time
       ↓
   Find failures / false positives
       ↓
   Add regression test
       ↓
   Improve policy / check
       ↓
   Release improvement
       └──────────────→ next server audit
```

This creates a compounding asset:

**production incident → reproducible case → regression test → better check/policy → safer remediation → better future audits.**

Security knowledge becomes executable and version-controlled instead of remaining tribal knowledge.

---

# How this makes development easier

VPS Shield is designed to reduce the security tax on development rather than become another operational burden.

### 1. Faster server bring-up

Instead of manually remembering dozens of security checks, run one audit and get a structured posture report.

### 2. Safer changes

Developers can inspect proposed remediation before applying it. Backups and verification reduce the risk of turning a security improvement into an outage.

### 3. Repeatability

The same baseline can be applied and evaluated across development, staging and production hosts.

### 4. Better debugging

When deployment behavior changes, security evidence can help distinguish an application problem from a host, network, SSH, firewall or container-posture problem.

### 5. Automation-friendly output

JSON evidence creates a clean path toward CI/CD gates, dashboards, APIs, fleet inventory and historical posture analytics.

### 6. Less context switching

The developer does not need to remember which command checks SSH, which command checks listeners, which command checks Docker or which file contains the previous hardening decision. VPS Shield turns those checks into one workflow.

---

# How this makes deployment and hosting easier

A secure deployment pipeline should not end at “the application started.” It should include the host and runtime that actually serve the application.

A practical flow becomes:

```text
Provision VPS
    ↓
Install base OS updates
    ↓
Install application/runtime stack
    ↓
VPS Shield audit
    ↓
Review score + evidence
    ↓
Dry-run remediation
    ↓
Apply approved hardening
    ↓
Deploy application
    ↓
Verify host + application posture
    ↓
Install/enable recurring audit
    ↓
Monitor drift
    ↓
Remediate / rollback / improve
```

This helps make hosting more predictable because security checks become part of the deployment lifecycle instead of a last-minute manual task.

For infrastructure using Docker, Coolify, reverse proxies, Cloudflare or runtime-security tooling, VPS Shield provides a common posture layer while allowing each specialized system to keep its own responsibility.

---

# Developer workflow

```bash
# 1. Clone
git clone https://github.com/MustafaAhmed007/Vps-Shield.git
cd Vps-Shield

# 2. Install
sudo bash install.sh

# 3. Audit — read only
sudo vps-shield audit

# 4. Machine-readable evidence
sudo vps-shield audit --json

# 5. Preview hardening
sudo vps-shield harden --dry-run

# 6. Apply only after review
sudo vps-shield harden --apply

# 7. Verify
sudo vps-shield verify

# 8. Inspect available integrations
sudo vps-shield integrations
```

**Important:** `harden` is dry-run by default. `--apply` is required for mutation.

Always keep a second administrative session or out-of-band recovery path before changing remote-access configuration.

---

# Recurring monitoring

The repository includes systemd service/timer templates for recurring audit execution.

The intended model is:

```text
systemd timer
      ↓
VPS Shield audit
      ↓
JSON evidence
      ↓
local report/history
      ↓
future dashboard/API/alerting
```

This is deliberately lightweight. A single VPS should not need a heavyweight control plane just to answer whether its baseline has drifted.

---

# Security boundaries and safety principles

VPS Shield follows several non-negotiable operational rules:

- **Audit before mutation.**
- **Dry-run before apply.**
- **Backup before risky configuration changes.**
- **Validate configuration before reload.**
- **Verify after mutation.**
- **Keep rollback available.**
- **Do not silently install dependencies.**
- **Do not silently change DNS or network exposure.**
- **Do not print detected secrets.**
- **Do not pretend a score proves security.**
- **Do not make destructive firewall changes by default.**
- **Treat integrations as explicit trust boundaries.**

The project is defensive tooling. Operators remain responsible for understanding their application, network topology, credentials, backups and recovery access.

---

# Policy as code

The baseline lives in the repository instead of existing only in documentation.

That creates a path toward:

- multiple security profiles
- environment-specific policies
- organization-wide baselines
- compliance mappings
- policy versioning
- CI security gates
- fleet drift detection
- machine-readable remediation plans

The long-term direction is to make policy **portable, reviewable and testable**.

---

# Evidence-first security

VPS Shield separates **observation** from **interpretation**.

A finding should ultimately be traceable to evidence from the running system:

```text
Host state
   ↓
Collector
   ↓
Raw signal
   ↓
Check
   ↓
Finding
   ↓
Severity / score
   ↓
Recommended action
   ↓
Verification
```

That makes the system easier to debug and significantly easier to evolve into an API, dashboard or fleet-management product later.

---

# Current CLI surface

| Command | Purpose | Mutates host? |
|---|---|---:|
| `audit` | Collect and evaluate security posture | No |
| `audit --json` | Emit machine-readable evidence | No |
| `harden --dry-run` | Preview remediation | No |
| `harden --apply` | Apply approved conservative remediation | Yes |
| `verify` | Verify expected hardening state | No |
| `integrations` | Probe optional security integrations | No |
| `rollback <backup-dir>` | Restore a supported backup | Yes |
| `version` | Show CLI version | No |

---

# CI and engineering quality

Every security behavior that matters should become a testable behavior.

Current engineering safeguards include:

- Bash syntax checks
- Audit smoke/regression tests
- GitHub Actions CI
- secret scanning through Gitleaks
- versioned policy
- documented threat model
- security disclosure policy
- contributor guidance

Future development should favor **small, testable security primitives** over giant all-in-one automation scripts.

---

# Roadmap: from VPS tool to security control plane

The current repository establishes the foundation. The planned evolution is intentionally layered:

### Phase 1 — Host baseline

- audit engine
- scoring/evidence
- conservative hardening
- verification
- rollback
- policy
- recurring audits

### Phase 2 — Defense adapters

- deeper Docker posture checks
- CrowdSec / Fail2ban controls
- Trivy vulnerability/SBOM evidence
- Falco runtime signals
- Wazuh telemetry
- Cloudflare access/edge posture
- Coolify posture checks

### Phase 3 — Security evidence platform

- normalized finding schema
- historical reports
- drift detection
- evidence retention
- remediation plans
- policy profiles
- signed/exportable evidence

### Phase 4 — Fleet control plane

- multiple VPS inventory
- centralized dashboard/API
- role-based access
- fleet-wide policy
- alerting
- deployment integration
- tenant isolation

### Phase 5 — Self-improving security system

- recurring false-positive analysis
- regression corpus
- recommendation quality measurement
- remediation success rates
- environment-aware policy
- automated evidence correlation
- controlled learning from production incidents

The objective is not to build another generic security dashboard. The objective is to create a **compounding security operating layer for developer infrastructure**.

---

# Product and business flywheel

The open-source CLI is the distribution engine.

```text
Open source
    ↓
Developer adoption
    ↓
Real VPS security evidence
    ↓
Trust + recurring usage
    ↓
Fleet / hosted needs emerge
    ↓
Paid monitoring + dashboard/API
    ↓
Compliance/evidence exports
    ↓
Managed hardening/support
    ↓
Enterprise policy + fleet controls
    ↓
More deployments
    └──────────────→ more learning + stronger product
```

Potential revenue layers include:

- managed VPS hardening
- fleet security monitoring
- hosted dashboard/API
- compliance/evidence exports
- enterprise policy management
- premium integrations
- support and security operations services

The repository remains useful as open source even as higher-value operational layers are added around it.

---

# Contributing

The best contribution is not merely another feature. It is a measurable improvement to the security loop.

Good contributions usually follow:

```text
Problem
  ↓
Reproduce
  ↓
Evidence
  ↓
Minimal fix
  ↓
Regression test
  ↓
Verification
  ↓
Documentation
```

If a production issue or false positive appears repeatedly, turn it into a test case so the project gets harder to break over time.

See `CONTRIBUTING.md` and `SECURITY.md` before contributing security-sensitive changes.

---

# License

MIT. See `LICENSE`.
