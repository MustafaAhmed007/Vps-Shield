# Changelog

## 0.2.0 — 2026-09-02

### Added
- policy-driven VPS audit lifecycle
- effective SSH configuration checks
- multi-firewall detection
- kernel/network posture checks
- Docker posture checks
- SUID/SGID and writable-path inventory
- package/update checks
- JSON evidence output
- conservative hardening with SSH validation
- backup and rollback primitives
- installer, tests and GitHub Actions CI
- architecture, hardening, threat model and roadmap documentation

### Safety
- hardening is explicit and supports dry-run
- SSH configuration is syntax-validated before reload
- third-party security services are not silently installed
