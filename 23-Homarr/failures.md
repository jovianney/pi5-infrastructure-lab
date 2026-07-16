# failures.md — Homarr Dashboard Troubleshooting Log

Real errors encountered while deploying Homarr and wiring it into the 
existing homelab stack.

---

## Failure 001 — Missing SECRET_ENCRYPTION_KEY
**Date:** July 2026  
**Problem:** Container started clean (`docker compose up -d` showed 
"Started"), but visiting `http://<pi-ip>:7575` returned an internal 
server error.  
**Diagnosis:** `docker logs homarr` showed: `Error: An error occurred 
while loading instrumentation hook: Invalid environment variables`. 
Newer Homarr versions require a `SECRET_ENCRYPTION_KEY` env var (used to 
encrypt stored integration credentials) or the app refuses to boot.  
**Fix:** Generated a key with `openssl rand -hex 32`, added it to the 
compose file under `environment:`, then force-recreated the container:
```bash
docker compose up -d --force-recreate
```
**Prevention:** Check a project's docs/GitHub README for required 
environment variables before first launch — don't assume ports and 
volumes are the only config a service needs.

---

## Failure 002 — UFW Blocking Pi-hole Access Over Tailscale
**Date:** July 2026  
**Problem:** `https://<tailscale-ip>/admin/` returned 403/connection 
refused when trying to reach Pi-hole's admin panel directly over 
Tailscale, even though it worked fine on the local LAN.  
**Diagnosis:** `sudo ss -tulnp | grep 443` confirmed `pihole-FTL` was 
listening on `0.0.0.0:443` (all interfaces, including Tailscale) — so 
binding wasn't the issue. `sudo ufw status` showed port 443 was missing 
entirely from the allowed rules list, despite dozens of other service 
ports being present.  
**Fix:**
```bash
sudo ufw allow 443/tcp
```
**Prevention:** When adding a new service or opening a new access path, 
verify UFW explicitly allows the port — a service listening correctly 
means nothing if the firewall never got the rule.

---

## Failure 003 — Nextcloud trusted_domains Entry Overwritten
**Date:** July 2026  
**Problem:** After adding `nextcloud.jovis.casa` as a trusted domain, the 
existing local IP entry (`192.168.12.239`) disappeared from the list.  
**Diagnosis:** Nextcloud's `trusted_domains` config is an indexed array. 
Ran `config:system:set trusted_domains 1 --value=nextcloud.jovis.casa` 
without first checking how many entries already existed — slot `1` was 
already occupied by the local IP, so the command overwrote it instead of 
adding a new entry.  
**Fix:** Restored the local IP to slot 1, then added the new domain to 
the next open slot (3):
```bash
docker exec -it nextcloud-nextcloud-1 php occ config:system:set trusted_domains 1 --value=192.168.12.239
docker exec -it nextcloud-nextcloud-1 php occ config:system:set trusted_domains 3 --value=nextcloud.jovis.casa
```
**Prevention:** Always run `config:system:get trusted_domains` first to 
see existing indexed entries before setting a new one — indexed configs 
overwrite silently if you guess the wrong slot number.

---

## Failure 004 — Self-Signed Certificate Rejected (Two Separate Services)
**Date:** July 2026  
**Problem:** Two different failures, same root cause:
1. `pihole.jovis.casa` returned a Cloudflare 502 Bad Gateway.
2. Homarr's Pi-hole integration setup threw a "Certificate error" (twice 
   — once for untrusted issuer, once for hostname mismatch against the 
   Tailscale IP).  

**Diagnosis:** Pi-hole's web interface uses a self-signed certificate 
(`CN=pi.hole`), not one from a trusted authority. Both `cloudflared` and 
Homarr reject unverified/mismatched certs by default rather than passing 
traffic through.  
**Fix:**
- For the Cloudflare Tunnel route: enabled **No TLS Verify** under 
  Origin request settings for that specific published route only.
- For Homarr: clicked **Trust certificate** on both the untrusted-issuer 
  and hostname-mismatch prompts during integration setup.  

**Prevention:** Any self-hosted service using a self-signed cert (Pi-hole, 
in this case) will need TLS verification bypassed by every downstream 
consumer connecting to it over HTTPS — expect this step whenever wiring 
a new tool into Pi-hole's API, and don't treat the first cert warning as 
a sign something else is broken.
