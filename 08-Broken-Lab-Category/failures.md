# 08-Broken-Lab — Failures & Incident Log

Intentional break/fix exercises to practice real IT troubleshooting and incident response.

---

## Incident 001 — DNS Outage Simulation
**Date:** June 2026
**Category:** Service Failure / DNS
**Command Used:** `sudo systemctl stop pihole-FTL`

**Problem:**
Pi-hole FTL service manually stopped to simulate DNS resolver outage.

**Symptoms:**
- nslookup google.com 192.168.12.240 returned connection refused on port 53
- Network devices silently fell back to T-Mobile gateway DNS
- Ad blocking completely disabled during outage
- Query logging stopped during downtime

**Fix:**
`sudo systemctl start pihole-FTL`

**Verification:**
nslookup google.com 192.168.12.240 returned valid IP 142.251.214.46

**Lesson:**
DNS failures can be silent. Devices fall back automatically but protection is gone. Always verify the resolver is active, not just that internet works.

---


## Incident 002 — Broken SSH Config
**Date:** June 2026
**Category:** Service Failure / SSH
**Command Used:** `echo "InvalidOption yes" | sudo tee -a /etc/ssh/sshd_config`

**Problem:**
Invalid option injected into sshd_config causing SSH daemon to fail on restart.

**Symptoms:**
- sudo systemctl restart ssh returned exit-code error
- SSH service failed with status=255/EXCEPTION
- All new SSH connections would be refused

**Fix:**
`sudo cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config`
`sudo systemctl restart ssh`

**Verification:**
SSH service returned active (running) — listening on port 22

**Lesson:**
Always backup sshd_config before editing. One bad line kills SSH access completely.
Test config with `sudo sshd -t` before restarting to catch errors safely.

---

## Bonus — Root Partition Not Using Full Drive
**Date:** June 2026
**Category:** Storage / Partition Management
**Root Cause:** Cloned SD card image onto T7 SSD — partition table copied as-is,
leaving 454GB unallocated on the 1TB drive.

**Symptoms:**
- df -h showed only 470GB total on a 1TB drive
- 53% usage despite having plenty of physical space

**Fix:**
`sudo raspi-config --expand-rootfs`
Reboot → partition expanded automatically to fill drive

**Verification:**
df -h showed 917GB total, 642GB free, usage dropped from 53% to 27%

**Lesson:**
After cloning an OS image to a larger drive always verify partition size matches
physical drive size. Auto-expand doesn't always fire on external SSDs with Pi 5.

---

## Incident 003 — Full Disk Recovery
**Date:** June 2026
**Category:** Storage / Disk Management
**Command Used:** `fallocate -l 600G ~/bigfile.img`

**Problem:**
Disk intentionally filled to 100% capacity to simulate storage exhaustion.

**Symptoms:**
- df -h showed /dev/sda2 at 100% with 48M remaining
- Package installation failed: "You don't have enough free space in /var/cache/apt/archives/"
- Security patches and updates could not be installed

**Fix:**
`rm ~/bigfile.img ~/bigfile2.img ~/bigfile3.img ~/bigfile4.img`

**Verification:**
df -h showed /dev/sda2 back to 27% usage with 642GB free

**Lesson:**
Linux reserves ~5% disk space for root processes so system doesn't immediately die at 100%.
But package installs, log writes, and database operations will fail.
Always monitor disk usage — set alerts at 80% in production environments.

---

## Incident 004 — Service Crash Recovery + Auto-Restart
**Date:** June 2026
**Category:** Service Management / Reliability
**Command Used:** `sudo kill -9 $(pgrep sleep)`

**Problem:**
Custom service killed with SIGKILL signal — no auto-restart configured.
Service stayed dead with no recovery.

**Symptoms:**
- systemctl status showed failed (Result: signal)
- code=killed, status=9/KILL
- Service stayed dead indefinitely

**Fix:**
Added to service file under [Service]:
Restart=on-failure
RestartSec=5s
Then: sudo systemctl daemon-reload

**Verification:**
Killed service again — came back automatically within 5 seconds
New PID confirmed it actually died and restarted

**Lesson:**
Production services should always have Restart=on-failure configured.
Pi-hole already has this built in. Custom services need it added manually.
Auto-restart = difference between 5 second recovery and full outage.

---
