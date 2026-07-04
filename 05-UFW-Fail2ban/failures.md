## Failure: Fail2ban couldn't find sshd log file

**Problem:** fail2ban-server threw "Have not found any log file for sshd jail" on startup.

**Diagnosis:** Raspberry Pi OS Bookworm uses systemd journal logging, not traditional /var/log/auth.log. Fail2ban's default config assumes the old-style log file exists — it doesn't on this OS.

**Fix:** Changed jail.local backend from default to `backend = systemd`, which tells Fail2ban to read from the journal instead of a log file.

**Prevention:** Any Debian 12/Bookworm-based system needs `backend = systemd` in Fail2ban jail configs — this is the new standard, not an edge case.