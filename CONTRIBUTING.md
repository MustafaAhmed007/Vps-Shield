# Contributing

1. Fork or branch from `main`.
2. Keep changes focused and testable.
3. Add a regression test for every bug fix.
4. Never commit secrets, private keys or production logs.
5. Document security-impacting behavior.
6. Run the local gates before opening a PR:

```bash
bash -n scripts/shield.sh
bash -n modules/audit.sh
bash -n modules/harden.sh
bash tests/test_audit.sh
```

## Security changes

Every remediation change should answer: what changes, why it is safe, how it is verified, and how it is rolled back.

## Quality bar

Prefer portable POSIX/Linux tooling, explicit failure handling, deterministic output, least privilege, idempotence and small composable functions.
