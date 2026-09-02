# Hardening Runbook

## Pre-flight

1. Confirm console/out-of-band recovery access.
2. Confirm a non-root administrative SSH key works in a second session.
3. Run `sudo ./scripts/shield.sh audit`.
4. Run `sudo ./scripts/shield.sh harden --dry-run`.
5. Save the audit report.

## Apply

```bash
sudo ./scripts/shield.sh harden
```

The conservative baseline changes SSH root/password authentication and selected network sysctls. It does not blindly rewrite firewall rules or install third-party services.

## Verify

```bash
sudo ./scripts/shield.sh verify
```

## Rollback

Use the backup directory printed during hardening:

```bash
sudo ./scripts/shield.sh rollback /var/lib/vps-shield/backups/<timestamp>
```

## Operational rule

Do not apply hardening to a production VPS for the first time without a recovery path and a tested rollback procedure.
