# 10 — Nextcloud: Self-Hosted Cloud Storage

## What This Is
Self-hosted Google Drive alternative running on Raspberry Pi 5 via Docker.
Accessible from local network and remotely via Tailscale VPN.

## Problem
No private cloud storage. Files either go to Google/iCloud (Big Tech owns your data)
or stay local with no remote access.

## Solution
Deployed Nextcloud using Docker Compose with a MariaDB database backend.
Configured UFW firewall rules and trusted domains for both local and remote access.

## Stack
- Nextcloud (stable) — web app and file management
- MariaDB 10.11 — database backend
- Docker Compose — container orchestration
- Tailscale — remote access via VPN mesh

## Access
| Method | URL |
|--------|-----|
| Local network | http://192.168.12.239:8080 |
| Remote (Tailscale) | http://100.121.71.88:8080 |

## What I Did
- Wrote docker-compose.yml defining Nextcloud and MariaDB services
- Opened port 8080 in UFW firewall
- Added trusted domains for local IP and Tailscale IP via occ CLI
- Verified file upload and remote access

## Resume Line
"Deployed self-hosted cloud storage with remote access using Docker and VPN mesh networking"

## Screenshots
- nextcloud-setup-page.png
- nextcloud-dashboard-local.png
- nextcloud-dashboard-tailscale.png
