# Roadmap

## 0.2 — Host security foundation
- [x] modular audit engine
- [x] effective SSH configuration checks
- [x] multi-firewall detection
- [x] kernel/network checks
- [x] Docker posture
- [x] SUID/writable-path inventory
- [x] package/update checks
- [x] JSON evidence
- [x] safe remediation + backup/rollback
- [x] CI and regression tests

## 0.3 — Defense adapters
- [ ] CrowdSec adapter
- [ ] Fail2ban configuration manager
- [ ] Trivy image/filesystem/SBOM adapter
- [ ] systemd timer + evidence retention
- [ ] stronger secret scanning with explicit redaction

## 0.4 — Runtime defense
- [ ] Falco adapter
- [ ] Wazuh adapter
- [ ] file/process integrity baselines
- [ ] alert routing

## 0.5 — Platform/access
- [ ] Cloudflare Zero Trust adapter
- [ ] Coolify posture scanner
- [ ] service exposure graph
- [ ] workload-specific security profiles

## 1.0 — Fleet platform
- [ ] signed policy bundles
- [ ] multi-VPS inventory
- [ ] centralized evidence API
- [ ] dashboard and score history
- [ ] team roles/audit trail
- [ ] managed security subscription

## Release gate
Every feature needs: implementation → test → failure-mode test → documentation → rollback story → measurable user outcome.
