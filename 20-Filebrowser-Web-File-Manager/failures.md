# Filebrowser — Failures & Debugging Log

Five distinct issues chained together during deployment — a good
lesson in not trusting the first plausible explanation and checking
one layer at a time: network, firewall, mount path, and app-level
rate limiting all looked identical from the outside ("it's not
loading" / "wrong credentials") but had completely different causes.

---

## Incident 1 — ARM64 Routing Bug on `latest` Tag

**Problem:** After deploying with `filebrowser/filebrowser:latest`,
the page loaded a blank screen with an infinite spinning-dots loader.
`curl` from the Pi itself returned `404 Not Found` on both `/` and
`/login`, even though `docker ps` showed the container as "healthy."

**Diagnosis:** Web search turned up a known upstream GitHub issue —
the `latest` image tag has a client-side routing bug specific to
**ARM64** builds (which is what the Pi 5 runs) where the root path
never redirects to `/login` properly. Confirmed via `docker exec`
into the container and manually checking the served HTML — real
content was there, just stuck in the loading state client-side.

**Fix:** Pinned the image to a known-stable version instead of
`latest`:
```yaml
image: filebrowser/filebrowser:v2.31.2
```

**Prevention:** Never use `latest` for production containers —
pin to a specific tested version. `latest` means "whatever got
uploaded most recently," bugs included, not "the best version."

---

## Incident 2 — UFW Never Opened the Port

**Problem:** Even before the ARM64 bug was found, the page wasn't
loading in the browser at all from the Mac.

**Diagnosis:** `sudo ufw status` showed rules for every other service
(8080, 8090, 8096, etc.) but no rule for 8083 — the new port was
never added to the firewall's allow list.

**Fix:**
```bash
sudo ufw allow 8083/tcp
```

**Prevention:** Every new service needs its own `ufw allow` rule —
this doesn't happen automatically just because Docker exposes the
port. Add it to the standard deployment checklist for future services.

---

## Incident 3 — Database Mount Path Mismatch

**Problem:** After fixing Incidents 1 and 2, login attempts failed
with "wrong credentials" even using the password Filebrowser itself
generated and printed in the logs.

**Diagnosis:** The original compose file mounted the database at
`/database/filebrowser.db`, but `docker exec filebrowser cat
/.filebrowser.json` showed this version of the app actually expects
its database directly at `/database.db` (no subfolder). Since the
mount path didn't match, Docker created a brand new empty database
*inside* the container instead of connecting to the real one — every
container rebuild wiped out any login changes.

**Fix:** Updated the compose file's volume mount to match the path
the app's own config file specified:
```yaml
- /home/jovi/docker/filebrowser/filebrowser.db:/database.db
```

**Prevention:** Don't assume a mount path from documentation or
memory — check `docker exec <container> cat <config-file>` to
confirm the app's *actual* expected path before wiring up volumes.
Also: **verify nano actually saved.** The first attempt at this fix
silently failed to save (`Ctrl+O` didn't fully register before
`Ctrl+X`), and the container was rebuilt against the old, unchanged
file — always `cat` the file back immediately after editing to
confirm the edit stuck, *before* rebuilding.

---

## Incident 4 — Rate-Limit Lockout After Failed Logins

**Problem:** After correctly changing the username/password inside
the app, logging back in with the new credentials failed repeatedly
with `403` errors — even a full container restart didn't clear it.

**Diagnosis:** `docker logs -f filebrowser` while attempting to log
in showed a wall of `/api/login: 403` entries from the same source
IP. Filebrowser has built-in brute-force protection that temporarily
bans an IP after repeated failed attempts — and that ban state is
stored in the database file itself, not just in memory, so a simple
`docker compose restart` doesn't clear it.

**Fix:** Bypassed the web UI's rate limiter entirely by resetting the
password directly through Filebrowser's CLI tool, talking straight to
the database file:
```bash
docker stop filebrowser
docker run --rm -it \
  -v /home/jovi/docker/filebrowser/filebrowser.db:/database.db \
  filebrowser/filebrowser:v2.31.2 \
  -d /database.db users update admin --password NEWPASSWORD
docker start filebrowser
```

**Prevention:** If a web login is rate-limited, don't keep retrying
through the UI — go straight to the app's CLI/database tooling.
Also note: the container's ENTRYPOINT is already `filebrowser`, so
CLI commands only need the *arguments* (`-d /database.db ...`), not
the binary name again — repeating it throws `unknown command`.

---

## Incident 5 — Local IP Unreachable While Away From Home

**Problem:** After everything above was fixed, the page still
wouldn't load — looked identical to Incident 1 all over again.

**Diagnosis:** Was testing `http://192.168.12.239:8083` while away
from the house. That's the Pi's **local network IP** — only reachable
by devices on the same home wifi. Nothing was actually broken.

**Fix:** Used the Tailscale IP instead, which routes in from
anywhere:
```
http://100.121.71.88:8083
```

**Prevention:** When troubleshooting "it won't load" while away from
home, check *which* IP is being used before touching any config —
local `192.168.x.x` addresses only work on the home network, Tailscale
`100.x.x.x` addresses work from anywhere.

---

## Final State
Container healthy, database persisting correctly across rebuilds,
accessible at `https://filebrowser.jovis.casa` from any network via
Cloudflare Tunnel.

**Resume line:** *"Debugged a multi-layer container deployment issue
spanning an architecture-specific upstream bug, firewall configuration,
volume mount path mismatches, and application-level rate limiting —
isolating each layer independently rather than assuming a single cause."*
