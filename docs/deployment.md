# Deployment

## Fresh VPS

```bash
git clone https://github.com/MustafaAhmed007/Vps-Shield.git
cd Vps-Shield
sudo bash install.sh
sudo vps-shield audit
```

## Safe hardening sequence

```bash
sudo vps-shield audit --json > before.json
sudo vps-shield harden --dry-run
# Confirm recovery access and a second working admin session.
sudo vps-shield harden --apply
sudo vps-shield verify
sudo vps-shield integrations
```

## Recurring audit

```bash
sudo cp systemd/vps-shield-audit.service /etc/systemd/system/
sudo cp systemd/vps-shield-audit.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now vps-shield-audit.timer
sudo systemctl list-timers vps-shield-audit.timer
```

## Rollback

```bash
sudo vps-shield rollback /var/lib/vps-shield/backups/<timestamp>
```

## Production checklist

- [ ] Provider console/recovery access tested
- [ ] Non-root SSH key login tested in a second session
- [ ] Firewall rules reviewed
- [ ] Public listeners reviewed
- [ ] Backups verified independently
- [ ] Audit JSON retained for evidence
- [ ] Monitoring/alerting configured
- [ ] Application secrets stored outside source control
- [ ] Rollback tested
