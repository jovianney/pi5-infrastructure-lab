# Failures Log — Grafana + Prometheus Monitoring Stack

Seven distinct root causes, stacked on top of each other, standing between the Pi-hole exporter and a working dashboard. Each one diagnosed with evidence before moving to the next — documented here in the order they were actually found.

---

## Failure 001 — Pi-hole Admin Panel 403 via Tailscale IP
**Date:** 2026-07-11
**Problem:** Accessing Pi-hole's admin panel over the Tailscale IP returned `403 Forbidden`
**Diagnosis:** Pi-hole v6's webserver ACL only trusts the local subnet by default; Tailscale's 100.x.x.x range gets treated as external even though it's genuinely the same device
**Fix:** SSH local port forward to reach Pi-hole as if local: `ssh -L 8081:localhost:443 jovi@100.121.71.88`, then browse `https://localhost:8081/admin/`
**Prevention:** For any service with an IP-based ACL, an SSH tunnel sidesteps the restriction without touching the service's own config

---

## Failure 002 — SSH Tunnel Pointed at Wrong Port (Mystery nginx)
**Date:** 2026-07-11
**Problem:** Tunneling to port 80 still returned `403 Forbidden`, even locally
**Error:** `curl -I http://localhost:80` → `Server: nginx`
**Diagnosis:** An unrelated `nginx` process was squatting on port 80. Pi-hole's actual webserver (`pihole-FTL`) was listening on port 443 the whole time — confirmed via `sudo ss -tulpn | grep ':80\|:443'`
**Fix:** Re-tunneled to port 443 instead: `ssh -L 8081:localhost:443 jovi@100.121.71.88`
**Prevention:** Never assume a service's port without checking `ss -tulpn` first — a "port already serving something" doesn't mean it's serving the *right* something

---

## Failure 003 — docker-compose.yml Indentation Breaking Repeatedly
**Date:** 2026-07-12 to 2026-07-13
**Problem:** Multiple `nano` edits over SSH to add new services (`pihole-exporter`) resulted in YAML indentation errors — `additional properties 'pihole-exporter' not allowed`
**Diagnosis:** `nano`'s auto-indent behavior over SSH silently misaligns YAML when pasting or typing multi-line blocks, especially nested list items
**Fix:** Abandoned `nano` for structural edits; used `cat > file << 'EOF' ... EOF` heredocs to overwrite the whole file cleanly every time
**Prevention:** For any YAML file requiring multiple nested keys, write it fresh via heredoc rather than editing incrementally in `nano`. Verify with `grep -n "^  [a-z]" docker-compose.yml` before running `docker compose up`

---

## Failure 004 — Pi-hole DNS Silently Down (systemd-resolved Port Conflict)
**Date:** 2026-07-13
**Problem:** Pi-hole dashboard showed "DNS server failure"; `dig` queries against Pi-hole timed out even when run locally on the Pi itself
**Error:** `dnsmasq: failed to create listening socket for port 53: Address in use`
**Diagnosis:** `systemd-resolved`'s DNS stub listener was competing with Pi-hole's `dnsmasq` for port 53. `pihole status` falsely reported success because it only checked that the service process existed, not that its listener actually bound
**Fix:**
```bash
sudo mkdir -p /etc/systemd/resolved.conf.d
echo -e "[Resolve]\nDNSStubListener=no" | sudo tee /etc/systemd/resolved.conf.d/no-stub.conf
sudo systemctl restart systemd-resolved
sudo systemctl restart pihole-FTL
```
**Prevention:** On any Debian/Ubuntu system running a custom DNS resolver, disable `systemd-resolved`'s stub listener before installing Pi-hole (or any service needing port 53) to avoid this conflict entirely

---

## Failure 005 — Docker Bridge Network Unable to Reach LAN IPs
**Date:** 2026-07-13
**Problem:** `pihole-exporter` (and a throwaway `curl` test container) timed out completely trying to reach Pi-hole's LAN IP, despite `curl` succeeding instantly when run directly on the Pi's own terminal
**Error:** `Operation timed out` after 130+ seconds, from a container on the default Docker bridge network
**Diagnosis:** Docker's isolated bridge network could not route to the LAN subnet on this Pi's specific network/firewall configuration
**Fix:** Switched the entire stack (`node-exporter`, `prometheus`, `grafana`, `pihole-exporter`) to `network_mode: "host"`, giving every container direct access to the Pi's real network stack instead of Docker's virtual one
**Prevention:** When a container can reach the internet but not the LAN, test with a disposable container (`docker run --rm curlimages/curl ...`) on the same network before assuming it's an app-level bug — it may be the network mode itself

---

## Failure 006 — Pi-hole App Password Rejected (Feature Not Enabled)
**Date:** 2026-07-13
**Problem:** Every generated Pi-hole app password returned `"message":"password incorrect"` when tested directly against the API with `curl`, across three separately generated passwords
**Diagnosis:** The app-password authentication feature itself had not actually been toggled on in Pi-hole's settings yet — every password generated before that toggle was flipped was valid data, but the auth system wasn't accepting app-password logins at all
**Fix:** Enabled the app-password feature in Pi-hole Settings → Web Interface/API (Expert mode), regenerated the password, re-tested with `curl` and confirmed `"message":"app-password correct"` before updating the exporter's config
**Prevention:** When repeated auth attempts fail with the *same* generic error despite fresh credentials, test the raw API directly with `curl` to isolate whether it's a credentials problem or a feature-availability problem

---

## Failure 007 — TLS Certificate SAN Mismatch (IP vs Hostname)
**Date:** 2026-07-13
**Problem:** With the correct password confirmed, the exporter still failed: `tls: failed to verify certificate: x509: cannot validate certificate for 192.168.12.239 because it doesn't contain any IP SANs`
**Diagnosis:** Pi-hole's self-signed TLS certificate was issued for the hostname `pi.hole`, not for its IP address — connecting via IP will always fail certificate validation regardless of trust settings
**Fix:** Added a manual host mapping inside the container so it resolves `pi.hole` to the correct LAN IP, matching what the certificate actually expects:
```yaml
extra_hosts:
  - "pi.hole:192.168.12.239"
environment:
  - PIHOLE_HOSTNAME=pi.hole
```
**Prevention:** When connecting to any self-signed HTTPS service, check the certificate's Subject/SAN fields (`curl -v` shows this) before assuming an IP will work — most self-signed certs are issued for a hostname, not an IP

---

## Failure 008 — Wrong Environment Variable Name for TLS Skip-Verify
**Date:** 2026-07-13
**Problem:** After fixing the hostname mismatch, a new TLS error appeared: `x509: certificate signed by unknown authority` — expected, since it's self-signed, but the `SSL_SKIP_VERIFY=true` setting wasn't suppressing it
**Diagnosis:** `SSL_SKIP_VERIFY` was an assumed variable name based on convention from other exporters, not the actual variable this specific tool (`ekofr/pihole-exporter`) checks for
**Fix:** Confirmed the correct variable via the project's documentation and swapped it in: `SKIP_TLS_VERIFICATION=true`
**Prevention:** Never assume an environment variable name is universal across tools/forks, even when the concept (skip TLS verification) is common — check the specific project's README or source before guessing

---

## Summary

The Pi-hole dashboard "No data" symptom looked like one bug from the outside. It was actually eight independent, correctly-diagnosed root causes stacked in sequence — a network ACL, a wrong port assumption, a broken editor workflow, a DNS service conflict, a Docker networking limitation, a disabled auth feature, a certificate hostname mismatch, and a wrong variable name. Each one was isolated with a direct test (`curl`, `dig`, `ss`, `docker logs`) before moving to the next, rather than guessing multiple fixes at once.
