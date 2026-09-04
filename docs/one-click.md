# One-Click Installation & Environment Contract

VPS Shield is designed so the operator should not spend days resolving dependencies, discovering missing files, or manually reconstructing the intended setup.

## Installation contract

From a fresh checkout:

```bash
sudo bash install.sh
```

The installer:

1. validates that it is running with root privileges;
2. checks the minimal local command contract;
3. installs the VPS Shield runtime under `/usr/local/lib/vps-shield`;
4. creates the `/usr/local/bin/vps-shield` command;
5. creates protected report, backup and research directories;
6. runs `vps-shield version`;
7. runs `vps-shield doctor`;
8. stops with an actionable failure if a required baseline command is missing.

The installer does **not** silently install arbitrary packages or modify network/authentication configuration. Optional capabilities are detected and reported instead.

## Doctor

Run:

```bash
sudo vps-shield doctor
```

The doctor separates required shell/runtime capabilities from optional capabilities such as `curl`, `sshd`, and `systemd`.

This creates a simple environment contract that can be reused by deployment automation, CI, images and future provisioning adapters.

## Recommended production bootstrap

```text
Provision host
    ↓
Install OS/runtime dependencies
    ↓
Install VPS Shield
    ↓
Doctor
    ↓
Read-only audit
    ↓
Review evidence
    ↓
Dry-run hardening
    ↓
Apply approved changes
    ↓
Verify
    ↓
Enable recurring audit
```

## Design rule

One-click means **one entry point**, not uncontrolled automation. VPS Shield should remove setup friction while keeping security-sensitive mutations explicit and reviewable.
