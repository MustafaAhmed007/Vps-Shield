# Architecture

VPS Shield is a policy-driven host security layer.

```text
CLI → Policy → Collectors → Checks → Score → Evidence
                         ↓
                    Remediation
                         ↓
                 Backup → Change → Verify
                         ↓
                      Rollback
```

## Principles

- Read-only audit is safe by default.
- Mutations require root and are explicit.
- Every mutation creates a backup first.
- SSH changes are syntax-tested before reload.
- Third-party integrations are explicit adapters, never hidden dependencies.
- JSON evidence is the stable contract for future APIs and dashboards.
- Checks must be deterministic and regression-tested.

## Integration contract

Future adapters should expose `detect`, `audit`, `remediate`, `verify`, and `rollback` where applicable. Each adapter must document privileges, network calls, side effects, failure behavior and recovery.
