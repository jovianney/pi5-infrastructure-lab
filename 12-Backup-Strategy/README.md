# 12 — Backup Strategy + Disaster Recovery

## What This Is
Automated backup system for critical Pi infrastructure configs and Docker volumes.
Runs nightly via cron job and saves dated backups to local NAS storage.

## Problem
A single drive failure with no backup strategy means total data loss.
Manual backups are unreliable — humans forget, automation doesn't.

## Solution
Wrote a bash script that backs up all critical configs and Docker volumes
into dated folders. Scheduled via cron job to run automatically at 2am daily.

## What Gets Backed Up
| Item | Type | Why |
|------|------|-----|
| /etc/samba | Config | NAS share configuration |
| /etc/pihole | Config | DNS blocklist settings |
| /etc/dhcpcd.conf | Config | Network configuration |
| /etc/rc.local | Config | Boot startup script |
| nextcloud docker-compose.yml | Config | Nextcloud deployment blueprint |
| sparky docker-compose.yml | Config | SparkyFitness deployment blueprint |
| nextcloud_data volume | Data | Actual Nextcloud files |
| sparky_db_data volume | Data | SparkyFitness nutrition database |

## What Doesn't Get Backed Up (And Why)
- OS files — reflash takes 10 minutes, not worth the storage
- Docker images — re-downloaded automatically from Docker Hub
- Pi-hole blocklists — re-downloaded automatically on setup

## Backup Location

/home/jovi/shares/backups/automated/YYYY-MM-DD/
New dated folder created for every backup run. History preserved.

## Cron Schedule
0 2 * * * sudo /home/jovi/backup.sh
Runs every night at 2:00am automatically.

## Disaster Recovery Plan
1. Flash fresh Raspberry Pi OS to new drive
2. Install dependencies (Docker, Samba, Pi-hole, Tailscale, Fail2ban, UFW)
3. Pull GitHub repo for all configs and documentation
4. Restore /etc/samba, /etc/pihole, /etc/dhcpcd.conf, /etc/rc.local from backup
5. cd into docker folders and run docker compose up -d
6. Restore Docker volumes from .tar.gz backup files
7. Verify all services running with docker ps

## Future Improvements
- Add AWS S3 offsite backup (Level 6)
- Implement RAID 1 across two WD Elements 6TB drives (Level 3)
- Add backup verification and email alerts

## Resume Line
"Designed and implemented automated backup strategy with tiered retention and documented disaster recovery procedures"

## Screenshots
- crontab-scheduled.png
- backup-folder-contents.png
