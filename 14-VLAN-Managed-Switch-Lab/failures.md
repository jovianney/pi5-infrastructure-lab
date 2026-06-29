# Failures & Troubleshooting — VLAN Managed Switch Lab

## Issue 001 — SSH tunnel couldn't handle switch redirects
**What happened:** Tried using SSH port forwarding (-L flag) to access switch web UI through the Pi. Login page loaded but after submitting credentials the session broke — switch redirects to a frameset that the tunnel couldn't follow.
**Error:** ERR_EMPTY_RESPONSE after login
**Fix:** Switched to SSH SOCKS proxy (-D flag) instead of port forwarding. SOCKS proxy routes all browser traffic through the Pi so redirects work correctly.
**Command that worked:**
```bash
ssh -D 9090 -N jovi@100.121.71.88
```
**Lesson:** SSH -L (port forward) works for simple single-page apps. SSH -D (SOCKS proxy) is needed when the target uses redirects, frames, or multiple resource requests.

## Issue 002 — Switch default IP (192.168.0.1) unreachable
**What happened:** TP-Link TL-SG108E default IP is 192.168.0.1 but home network is 192.168.12.x — different subnets, Pi couldn't reach it.
**Fix:** Switch picked up an IP via DHCP from the router automatically. Found it at 192.168.12.210 using nmap scan from the Pi.
**Command used:**
```bash
sudo nmap -sn 192.168.12.0/24
```
**Lesson:** Always scan the network to find a device's actual IP before assuming it's using the default. Managed switches with DHCP enabled will grab an IP from the router automatically.

## Issue 003 — Switch forced password change loop
**What happened:** Switch required password change on first login but after submitting new password the page broke and kept redirecting back to the password change screen.
**Root cause:** SSH tunnel dropping during the password change redirect before the session cookie could be saved.
**Fix:** Used curl from the Pi to submit the password change directly, bypassing the browser tunnel entirely. Then logged in via SOCKS proxy with the new password.
**Lesson:** When a web UI breaks during a form submission through a tunnel, use curl to submit the form directly from the machine that has network access to the target.

## Issue 004 — Tailscale not working (Mac side)
**What happened:** Couldn't SSH into Pi via Tailscale — connection refused.
**Root cause:** Tailscale app on Mac was not running. Mac Tailscale needs to be active for the VPN mesh to work.
**Fix:** Opened Tailscale app on Mac and connected.
**Lesson:** Tailscale must be running on BOTH devices for the mesh to work. Always check the menu bar icon before troubleshooting deeper network issues.

## Issue 005 — WiFi not persisting as backup on Pi reboot
**What happened:** Attempted to configure WiFi as a backup connection on the Pi so it would stay reachable if ethernet was disconnected. WiFi would connect manually but not survive reboots.
**Root cause:** Pi 5 running Bookworm OS uses a hybrid network stack (dhcpcd + wpa_supplicant) that requires specific configuration. The preconfigured.nmconnection file exists but NetworkManager isn't fully active.
**Partial fix:** Manually connecting with wpa_supplicant works for the session but doesn't persist.
**Status:** Deferred — not required for VLAN lab. Pi stays reachable via Tailscale over ethernet through the switch.
**Lesson:** Pi 5 Bookworm network configuration is more complex than older Pi OS versions. Document for future resolution.