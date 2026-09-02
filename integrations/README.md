# Integration Layer

VPS Shield keeps external defenses optional and explicit.

| Adapter | Purpose | Default |
|---|---|---|
| Docker | container/socket posture | audit when installed |
| Fail2ban | brute-force defense | detect only |
| CrowdSec | collaborative blocking | detect only |
| Trivy | vulnerability + SBOM evidence | not installed automatically |
| Falco | runtime event detection | not installed automatically |
| Wazuh | SIEM/host monitoring | not installed automatically |
| Cloudflare Zero Trust | identity-aware access | not installed automatically |
| Coolify | platform/application posture | not installed automatically |

## Adapter rule

No integration may silently install software, open ports, change DNS, or modify authentication. Each integration must provide explicit install prerequisites, audit behavior, remediation behavior, verification, rollback and data-privacy notes.

## Recommended deployment pattern

```text
Internet
   ↓
Provider / Cloudflare edge
   ↓
Firewall
   ↓
SSH / reverse proxy
   ↓
Host controls (VPS Shield)
   ↓
Runtime controls (Falco/Wazuh/CrowdSec)
   ↓
Containers / applications
```
