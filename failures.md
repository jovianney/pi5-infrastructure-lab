# failures.md — JoviOS Troubleshooting Log

Real errors encountered while building the Pi 5 infrastructure lab.
Documenting failures is part of the process.

---

## Failure 001 — Wrong OS (Debian Trixie)
**Date:** May 2026  
**Problem:** Installed Debian 13 Trixie instead of Bookworm Legacy.
lr-flycast failed to build due to GCC incompatibility.  
**Root Cause:** Pi 5 + Trixie has GCC version conflicts with lr-flycast  
**Fix:** Reflashed SD card with Raspberry Pi OS Legacy (Bookworm)  
**Lesson:** Always check OS compatibility before installing emulators

---

## Failure 002 — Pi 5 Kernel Page Size
**Date:** May 2026  
**Problem:** Dreamcast games crashed immediately on launch  
**Root Cause:** Pi 5 uses 16KB memory pages by default.
lr-flycast expects 4KB pages  
**Fix:** Added kernel=kernel8.img to /boot/firmware/config.txt  
**Lesson:** Pi 5 has unique kernel quirks that break certain emulators

---

## Failure 003 — SSH Host Key Mismatch
**Date:** May 2026  
**Problem:** WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED after reflash  
**Root Cause:** New OS = new host key, Mac still had old key cached  
**Fix:** ssh-keygen -R 192.168.12.240  
**Lesson:** Always clear known_hosts after reflashing

---

## Failure 004 — ran apt on Mac instead of Pi
**Date:** May 2026  
**Problem:** Ran sudo apt update on Mac terminal instead of SSH'd into Pi  
**Root Cause:** Wrong terminal window open  
**Fix:** SSH into Pi first, then run commands  
**Lesson:** Always check your terminal prompt before running commands

---

## Failure 005 — SD Card Cracked During Case Install
**Date:** May 2026  
**Problem:** SD card stopped working after installing Dreamcast case  
**Root Cause:** Physically cracked SD card while installing case  
**Fix:** Ordered new Samsung PRO Plus 512GB microSD  
**Lesson:** Always remove SD card BEFORE installing any case.
Always image SD card before hardware changes

---

## Failure 006 — Audio Not Working in RetroPie
**Date:** May 2026  
**Problem:** VolumeControl::init() Failed to find mixer elements  
**Root Cause:** Known Pi 5 + Bookworm + RetroPie audio bug.
Mixer element names changed in newer kernels  
**Fix:** Set audio through RetroPie audiosettings menu → HDMI 1.
Deleted corrupted .asoundrc file  
**Lesson:** Use RetroPie audio settings menu, not manual config files

---

## Failure 007 — Controller Not Working in Games
**Date:** May 2026  
**Problem:** 8BitDo Pro 3 worked in EmulationStation menu but not in games  
**Root Cause:** RetroArch defaulting to wrong joypad driver  
**Fix:** Added input_joypad_driver = "udev" to
/opt/retropie/configs/all/retroarch.cfg  
**Lesson:** Always check joypad driver setting when controller works
in menu but not in games

---

## Failure 008 — Double Game Entries in EmulationStation
**Date:** May 2026  
**Problem:** Each game showed up twice in RetroPie  
**Root Cause:** Both GDI and CUE files in same folder.
RetroPie sees each as a separate game  
**Fix:** Hide CUE with .cue.bak rename. Use GDI only  
**Lesson:** Only keep ONE format per game. GDI preferred over CUE

---

## Failure 009 — Save States Broke After Renaming ROMs
**Date:** May 2026  
**Problem:** Load state stopped working after renaming ROM files  
**Root Cause:** Save state filename must exactly match ROM filename  
**Fix:** Renamed .state files to match new ROM filename  
**Lesson:** If you rename a ROM, rename its save states too

---

## Failure 010 — Controller Drift on Right Stick
**Date:** May 2026  
**Problem:** Camera moving on its own in Sonic Adventure 2  
**Root Cause:** Analog stick sending phantom inputs (controller drift)  
**Fix:** Restart fixed temporarily. Long term: recalibrate or replace  
**Lesson:** Controller drift can cause phantom inputs — restart first,
recalibrate if persists
