# Failures Log — Security Camera Project

---

## Failure 001 — MotionEye Log Directory Permission Denied
**Date:** 2026-05-29
**Problem:** MotionEye service failed to start after installation
**Error:** `CRITICAL: log directory "/var/log" does not exist or is not writable`
**Diagnosis:** MotionEye needed its own log subdirectory with correct ownership
**Fix:**
```bash
sudo mkdir -p /var/log/motioneye
sudo chown motion:motion /var/log/motioneye
```
Then updated `/etc/motioneye/motioneye.conf` to set `log_path /var/log/motioneye`
**Prevention:** After installing any new service check log path permissions before starting

---

## Failure 002 — UFW Firewall Blocking MotionEye Dashboard
**Date:** 2026-05-29
**Problem:** Browser showed "This site can't be reached" on port 8765
**Diagnosis:** UFW had no rule allowing port 8765
**Fix:** `sudo ufw allow 8765/tcp`
**Prevention:** After installing any web service immediately add UFW rule for its port

---

## Failure 003 — Wrong Docker Image Architecture
**Date:** 2026-05-29
**Problem:** Pulled amd64 MotionEye Docker image on arm64 Pi
**Error:** `WARNING: The requested image's platform (linux/amd64) does not match detected host platform (linux/arm64/v8)`
**Diagnosis:** Pi 5 is arm64, ccrisan MotionEye image had no proper arm64 build
**Fix:** Switched from Docker to pip install method which pulled correct arm64 packages
**Prevention:** Always verify Docker image architecture matches host before pulling

---

## Failure 004 — H.264/OMX Codec Unavailable
**Date:** 2026-05-29
**Problem:** Motion triggered recording failed silently
**Error:** `Could not open codec Encoder not found`
**Diagnosis:** H.264/OMX hardware encoder not available on Pi 5 Bookworm
**Fix:** Changed movie format from H.264/OMX to H.264 in MotionEye settings
**Prevention:** Use software encoders on Pi 5, hardware OMX encoding is not supported

---

## Failure 005 — Reolink RTSP Toggle Failed on First Attempt
**Date:** 2026-05-29
**Problem:** Enabling RTSP in Reolink app returned "Failed to set. Please try again."
**Diagnosis:** Temporary app connection glitch, not a firmware or hardware issue
**Fix:** Second attempt succeeded without any changes
**Prevention:** Always retry once before deeper troubleshooting on app based settings
