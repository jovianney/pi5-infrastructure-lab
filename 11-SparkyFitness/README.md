# 11 — SparkyFitness: Self-Hosted Nutrition Tracker

## What This Is
Self-hosted MyFitnessPal alternative running on Raspberry Pi 5 via Docker.
Tracks food, macros, calories, and fitness goals privately on your own server.

## Problem
MyFitnessPal and similar apps collect your personal health data and sell it.
Subscription costs money. No control over your own nutrition data.

## Solution
Deployed SparkyFitness using Docker Compose with a PostgreSQL database backend.
Configured CORS trusted origins to allow access via both local network and Tailscale VPN.

## Stack
- SparkyFitness frontend — web UI served via nginx
- SparkyFitness server — backend API handling auth and data
- PostgreSQL 16 — database storing all nutrition and user data
- Docker Compose — orchestrating all three containers
- Tailscale — remote access via VPN mesh

## Access
| Method | URL |
|--------|-----|
| Local network | http://192.168.12.239:8090 |
| Remote (Tailscale) | http://100.121.71.88:8090 |

## What I Did
- Wrote docker-compose.yml with three services wired together
- Generated encryption key using Python for securing user data
- Debugged CORS rejection errors by reading server logs
- Added trusted origins for both local and Tailscale IPs
- Opened ports 8090 and 8091 in UFW firewall
- Verified login and dashboard accessible remotely

## Troubleshooting Notes
- Frontend crashed due to service name mismatch in Docker network
- CORS errors blocked signup from Tailscale IP — fixed via BETTER_AUTH_TRUSTED_ORIGINS
- Rate limiter triggered from repeated signup attempts — resolved by waiting

## Resume Line
"Deployed self-hosted fitness tracking platform using Docker Compose with PostgreSQL backend and remote access via VPN"

## Screenshots
- sparky-login-tailscale.png
- sparky-setup-food-db.png
- sparky-dashboard.png
