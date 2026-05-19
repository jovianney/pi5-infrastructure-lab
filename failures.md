## Dreamcast Emulation - lr-flycast Build Failure

**Date:** May 2026

**Problem:** lr-flycast would not build on RetroPie 4.8.11 + Debian 13 (Trixie)

**Error:**
core/deps/libzip/mkstemp.c:70:15: error: implicit declaration of function 'getpid'
make: *** Error 1

**What I tried:**
- sudo apt install flycast → package not found
- sudo apt install libretro-flycast → package not found
- git pull retropie-setup → already up to date
- Checked build logs → GCC compiler too strict on Debian 13

**Root cause:** Debian 13 (Trixie) GCC compiler incompatible with lr-flycast source code. Confirmed by RetroPie community on Reddit.

**Fix:** Reflashed SD card with Raspberry Pi OS Bookworm (Debian 12) Legacy 64-bit. lr-flycast installed via precompiled binary successfully.

---

## Dreamcast - Game Crashing on Launch

**Problem:** Sonic Adventure 2 crashed immediately back to EmulationStation

**What I tried:**
- video_driver = "gl" → crashed
- video_driver = "glcore" → crashed  
- video_driver = "vulkan" → not supported
- Converted .cue/.bin to .chd → still crashed

**Root cause:** Pi 5 uses 16KB memory pages, lr-flycast expects 4KB pages

**Fix:** Added kernel=kernel8.img to /boot/firmware/config.txt
This forces the older kernel which is compatible with lr-flycast

**Result:** Sonic Adventure 2 running at full speed ✅
