## Failure: SSH host key verification failed on reconnect

**Problem:** Attempting to SSH back into the Pi after a fresh SD card flash threw:
Host key verification failed.
Offending ECDSA key in /Users/jovi/.ssh/known_hosts

**Diagnosis:** The Mac's SSH client had the Pi's *old* host key cached from a previous OS install. Every fresh flash generates a brand-new host key — the Mac saw a "different" key claiming to be `retropi.local` and assumed a possible man-in-the-middle attack, refusing to connect as a safety measure.

**Fix:** Removed the stale cached key and reconnected clean:
```bash
ssh-keygen -R retropi.local
ssh jovi@retropi.local
```
Accepted the new fingerprint prompt.

**Prevention:** Expected behavior anytime the SD card gets reflashed — not a real security incident, just a stale cache. Run `ssh-keygen -R retropi.local` proactively after any reflash, before attempting to reconnect.

---

## Note: wlan0 vs eth0 interface choice

At the time of this install, the Pi was connected via WiFi, so `wlan0` was selected during setup. This was later reconsidered — a wired Raspberry Pi running always-on services like Pi-hole benefits from a stable ethernet connection rather than WiFi, which is more prone to drops and power-saving interference. The Pi was later migrated to a wired ethernet connection in a subsequent session.