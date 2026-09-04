# Multi-Aspect Auto-Research

VPS Shield includes a lightweight research/evidence path for infrastructure and security questions. It is intentionally provider-neutral and optional.

## Why research belongs in the security loop

Security findings often require context: a configuration may be intentional, a service may have a known exposure pattern, or a mitigation may differ by OS/runtime version.

The research layer turns that context into a repeatable evidence artifact rather than relying on memory or ad-hoc browser tabs.

```text
Finding / question
      ↓
Generate research aspects
      ↓
Threat model
Configuration
Vulnerabilities
Deployment
Recovery
Verification
      ↓
Cloud search when configured
      ↓
Local evidence fallback
      ↓
Direct URL evidence when supplied
      ↓
Persist research manifest + artifacts
      ↓
Human review / future automation
```

## CLI

```bash
sudo vps-shield research "Docker socket security"
sudo vps-shield research "OpenSSH hardening" --cloud
sudo vps-shield research "Coolify VPS exposure" --url https://example.com/security-guide
```

Research artifacts are stored under:

```text
/var/lib/vps-shield/research/<timestamp>-<topic>/
```

Each run contains one artifact per research aspect and a `manifest.json` describing the run.

## Cloud search

Cloud search is optional. Configure an HTTP JSON endpoint with:

```bash
export VPS_SHIELD_SEARCH_URL="https://your-search-service.example/api/search"
export VPS_SHIELD_SEARCH_HEADER="Authorization: Bearer <token>"
```

The adapter sends a minimal JSON request containing the research query. VPS Shield does not require a specific search vendor.

## Fallback model

The research engine remains useful without cloud credentials:

- local mode creates an evidence placeholder that identifies the required research aspect;
- `--url` can fetch operator-selected documentation directly when `curl` is available;
- future adapters can add local indexes, repository knowledge bases, or other evidence providers without changing the CLI contract.

## Safety

Research is read-only. It does not execute instructions returned by external sources, install packages, modify firewall rules, alter SSH, or deploy anything.

External content is evidence to review, not authority to execute.

## Future evolution

The same provider-neutral interface can later support:

- multiple search providers with fallback/routing;
- local repository/documentation retrieval;
- CVE/advisory feeds;
- vendor documentation adapters;
- evidence deduplication and source ranking;
- research-to-finding correlation;
- cached research to reduce latency/cost;
- signed evidence bundles.
