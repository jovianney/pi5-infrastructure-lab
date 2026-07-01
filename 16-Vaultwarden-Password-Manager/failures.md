# Failures & Lessons — Vaultwarden

## Deployment

Clean deploy — no failures. Single Docker container, no dependency conflicts, no port collisions with existing services (8082 was free). Ran correctly on the first attempt.

HTTPS access via Cloudflare Tunnel (`vaultwarden.jovis.casa`) was verified working out of the box — confirmed `HTTP/2 200` direct from Cloudflare's edge with full security headers, no manual SSL configuration needed.

## Resolved Item

`SIGNUPS_ALLOWED` was set to `true` during initial setup to allow account creation. Once all needed accounts were created, it was flipped to `false` and the container recreated, closing open registration on `vaultwarden.jovis.casa` to the public.
