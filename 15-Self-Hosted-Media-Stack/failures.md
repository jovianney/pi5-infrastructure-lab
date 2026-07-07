# Self-Hosted Media Stack — Failures & Lessons Learned

## Failure: Tailscale MagicDNS Resolution Bug

**Problem:** `jovis.casa` failed to resolve specifically on Mac/Chrome, 
while working fine on mobile data and other browsers.

**Diagnosis:** Confirmed Cloudflare DNS records correct, tunnel logs 
showed zero incoming requests (never reached the tunnel). Isolated to 
Chrome on Mac specifically. `dig @100.100.100.100 jovis.casa` (Tailscale's 
MagicDNS resolver) returned zero answers, while `dig @1.1.1.1 jovis.casa` 
resolved correctly — confirmed the VPN's own DNS resolver had a stuck 
forwarding state for this domain.

**Fix:** Disabled and re-enabled MagicDNS in the Tailscale admin console — 
force-refreshed the DNS forwarding state.

**Prevention:** When self-hosting behind a VPN mesh network, the VPN's 
resolver sits in front of ALL DNS queries on that device — even unrelated 
domains. A working tunnel + correct DNS records mean nothing if the 
client's resolver silently drops the query upstream.

---

## Failure: Custom CSS Silently Not Applying

**Problem:** Both hand-written Custom CSS (via Dashboard → Branding) and 
the Abyss theme failed to render, despite saving successfully server-side.

**Diagnosis:** Two separate bugs stacked on top of each other:
1. `view-source:` on the live site showed zero trace of the Branding 
   dashboard's Custom CSS in the actual page HTML — it wasn't injecting at all
2. Jellyfin's Kestrel webserver uses a build manifest that blocks serving 
   any static file not listed in it — abyss.css was reachable via curl 
   but silently rejected by the app since it wasn't a manifest-listed file

**Fix:** Injected the CSS content directly into an existing manifest-listed 
file (`main.jellyfin.[hash].css`) instead of adding a new file.

**Prevention:** When CSS "saves" but doesn't render, check the actual 
page source before assuming it's a caching or CDN issue — confirm the 
style tag or link is genuinely present in the served HTML first.

---

## Failure: qBittorrent Saving to Wrong Path

**Problem:** Downloads weren't showing up in Jellyfin's library.

**Diagnosis:** qBittorrent's docker-compose volume was mapped to 
`/home/jovi/media` — a leftover path from before the WD Elements 
migration, not the actual location Jellyfin was watching (`/mnt/wdelements`).

**Fix:** Updated the volume mapping to `/mnt/wdelements`, added Categories 
(movies/shows) with matching save paths.

**Prevention:** After migrating storage locations, audit every 
container's volume mounts — not just the ones you remember touching.

---

## Failure: qBittorrent Downloads Landing at Array Root Instead of Category Folders

**Problem:** New downloads weren't sorting into `movies/`/`shows/` despite 
categories being correctly configured with the right save paths.

**Diagnosis:** `qBittorrent.conf` had `Session\DisableAutoTMMByDefault=true` 
— despite the WebUI settings screen showing "Automatic" as the default 
torrent management mode, this underlying config key silently forced new 
torrents into Manual mode instead.

**Fix:**
```bash
docker exec qbittorrent sed -i 's/Session\\DisableAutoTMMByDefault=true/Session\\DisableAutoTMMByDefault=false/' /config/qBittorrent/qBittorrent.conf
docker restart qbittorrent
```

**Prevention:** When a WebUI setting doesn't seem to take effect, check 
the underlying config file directly — some qBittorrent settings have 
config keys that don't map 1:1 with the UI dropdown.

---

## Failure: Navidrome Crashed on Startup — Empty ND_BASEURL

**Problem:** Navidrome container stuck in a restart loop immediately after deploy.

**Diagnosis:** `docker logs navidrome` showed:
panic: chi: routing pattern must begin with '/' in '""/api/events'
The compose file had `ND_BASEURL=""` (empty string). Navidrome's router 
tried prepending this empty string to route paths, breaking pattern 
matching entirely on every request.

**Fix:** Removed the `ND_BASEURL` environment variable from the compose 
file completely (not just setting it empty) — Navidrome defaults to 
serving from root correctly when the variable isn't set at all.

**Prevention:** Empty string ≠ unset variable in Docker environment 
configs. If a variable isn't needed, omit it entirely rather than 
setting it to `""`.

---

## Failure: Samsung TV Developer Mode IP Mismatch

**Problem:** Apps2Samsung install failed with a Developer Mode IP 
mismatch error.

**Diagnosis:** Developer Mode on the TV requires the HOST machine's IP 
(the Mac doing the install), not the TV's own IP — easy to enter backwards.

**Fix:** Corrected the IP entered in TV Developer Mode settings to match 
the Mac's actual local IP.

**Prevention:** Always double-check which device's IP a setup wizard is 
actually asking for — "IP Settings" fields aren't always self-explanatory 
about which device they belong to.

---

## Failure: Daredevil Born Again Recognized as Two Separate Shows

**Problem:** Jellyfin was listing Daredevil Born Again Season 1 and 
Season 2 as two completely separate shows in the library.

**Diagnosis:** The two seasons were sitting in separate top-level folders 
instead of one show folder with season subfolders — Jellyfin's naming 
convention requires `Show Name/Season 01/`, `Show Name/Season 02/` under 
a single parent folder to recognize them as one series.

**Fix:** Restructured into `Daredevil Born Again/Season 01/` and 
`Daredevil Born Again/Season 02/` under one folder, triggered rescan.

**Prevention:** Always follow Jellyfin's exact folder naming convention 
for multi-season shows — one parent folder, `Season 0X` subfolders inside it.

---

## Failure: 19GB of Duplicate Media on Old Path

**Problem:** Disk space being consumed on T7 (root drive) unexpectedly.

**Diagnosis:** The pre-migration `/home/jovi/media` folder was still 
present on the T7 with the full original media library — a leftover from 
before the WD Elements array migration, now fully duplicated on the array.

**Fix:** Confirmed all content existed on `/mnt/wdelements`, then deleted 
the old `/home/jovi/media` folder entirely — reclaimed 19GB.

**Prevention:** After any storage migration, explicitly verify and delete 
old data locations — don't assume migration scripts or manual copies 
clean up after themselves.