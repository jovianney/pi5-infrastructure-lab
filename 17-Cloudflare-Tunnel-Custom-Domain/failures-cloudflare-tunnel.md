# Failures & Lessons — Cloudflare Tunnel + Custom Domain

## No Local Config File Found

**What happened:** While documenting this project, the first instinct was to check for a local tunnel config at `~/.cloudflared/config.yml` to see the ingress rules. That file doesn't exist on the Pi.

**Root cause:** This tunnel was set up as a **remotely managed tunnel** through the Cloudflare Zero Trust dashboard rather than a locally configured one. Remotely managed tunnels authenticate via a token (`cloudflared tunnel run --token <token>`) and pull their routing rules live from Cloudflare's servers — there's no local YAML file because there doesn't need to be one.

**Fix:** Confirmed this by checking `systemctl status cloudflared`, which showed the service running with a `--token` flag instead of a `--config` flag pointing at a local file. Cross-checked against the Cloudflare Zero Trust dashboard (Networks → Tunnels → jovi-pi-tunnel) and found all 6 routes listed there instead.

**Lesson:** Not every Cloudflare Tunnel setup works the same way. There are two valid configurations — locally managed (config file on disk) and remotely managed (token-based, dashboard-controlled). When troubleshooting or documenting a tunnel, check `systemctl status cloudflared` first to see which type you're actually running before hunting for a config file that might not exist by design.

## Log Noise (Non-Issue)

`sudo systemctl status cloudflared` showed several `ERR stream canceled by remote` lines in the recent log output. Initially flagged as a possible problem, but the tunnel's `Active: active (running)` status never changed and the Cloudflare dashboard reported `Healthy` the entire time. These errors were traced to abrupt connection terminations from repeated `curl` testing and browser hard-refreshes during unrelated Jellyfin CSS debugging earlier in the same session — not an actual tunnel fault.

**Lesson:** `ERR` lines in `cloudflared` logs aren't automatically a red flag. Always cross-check against the actual service status and dashboard health before treating log noise as a real incident.
