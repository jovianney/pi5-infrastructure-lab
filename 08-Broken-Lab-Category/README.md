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
jovi@retropi:~/pi5-infrastructure-lab $ cat ~/pi5-infrastructure-lab/08-Broken-Lab/README.md
# 08 — Broken Lab

Intentional break/fix exercises simulating real enterprise outages.
Each scenario documents a deliberate failure, its impact, recovery steps, and lessons learned.

## Purpose
- Practice incident response in a controlled environment
- Build troubleshooting muscle memory
- Document real diagnostic commands and recovery procedures
- Simulate what IT professionals face in production environments

## Scenarios

| # | Scenario | Status |
|---|----------|--------|
| 001 | DNS Outage — Pi-hole FTL stopped | ✅ Complete |
| 002 | Broken SSH Permissions | ⬜ Pending |
| 003 | Full Disk Recovery | ⬜ Pending |
| 004 | Service Crash Recovery | ⬜ Pending |

## Skills Demonstrated
- Linux service management (systemctl)
- DNS troubleshooting (nslookup)
- Incident documentation
- Recovery verification

## Resume Line
"Troubleshot simulated enterprise outages in homelab environment including DNS failures,
SSH misconfigurations, and disk recovery"
