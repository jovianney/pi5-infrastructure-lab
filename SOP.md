# SOP - RetroPie Pi 5 Setup Guide

## Prerequisites
- Raspberry Pi 5
- MicroSD card (64GB+ recommended)
- MacBook/PC with Raspberry Pi Imager installed
- Micro HDMI to HDMI cable
- TV or monitor

---

## Step 1 - Flash the SD Card

1. Open Raspberry Pi Imager
2. Select Device → Raspberry Pi 5
3. Select OS → Raspberry Pi OS (Legacy, 64-bit) Lite
   ⚠️ WARNING: Do NOT use the default Trixie version
   Must use Legacy (Bookworm/Debian 12) for emulator compatibility
4. Configure settings:
   - Hostname: retropi
   - Username: jovi
   - Password: your password
   - WiFi: your network
   - Enable SSH: yes
5. Flash to SD card

---

## Step 2 - First Boot

1. Insert SD card into Pi
2. Power on Pi
3. Wait 60 seconds
4. SSH in from Mac:
   ssh jovi@retropi.local
   (if fails use IP: ssh jovi@192.168.12.240)

---

## Step 3 - Update System

```bash
sudo apt update && sudo apt upgrade -y
```

---

## Step 4 - Install Pi-hole

```bash
curl -sSL https://install.pi-hole.net | bash
```

- Select your network interface
- Use Cloudflare DNS (1.1.1.1)
- Keep defaults for everything else
- Save the admin password shown at the end
- Admin panel: http://192.168.12.240/admin

---

## Step 5 - Install RetroPie

```bash
sudo apt install git -y
git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git retropie-setup
sudo ~/retropie-setup/retropie_setup.sh
```

- Select Basic Install
- Wait 20-45 minutes

---

## Step 6 - Install lr-flycast (Dreamcast Emulator)

```bash
sudo ~/retropie-setup/retropie_setup.sh
```

- Manage Packages
- Manage Optional Packages
- Find lr-flycast
- Install from precompiled binary ✅
  (NOT from source)

---

## Step 7 - Fix Dreamcast Kernel Issue

⚠️ CRITICAL - Without this Dreamcast games will crash

```bash
sudo nano /boot/firmware/config.txt
```

Add at the bottom:
kernel=kernel8.img

Save and reboot:
```bash
sudo reboot
```

Why: Pi 5 default kernel uses 16KB memory pages.
lr-flycast requires 4KB pages.
kernel8.img is the older kernel already on the Pi
that uses 4KB pages.

---

## Step 8 - Transfer BIOS Files

From Mac terminal (NOT SSHed into Pi):
```bash
scp ~/Downloads/dc_boot.bin ~/Downloads/dc_flash.bin jovi@retropi.local:/home/jovi/RetroPie/BIOS/dc/
```

Required files:
- dc_boot.bin
- dc_flash.bin

---

## Step 9 - Transfer ROMs

GBA example:
```bash
scp ~/Downloads/"game.gba" jovi@retropi.local:/home/jovi/RetroPie/roms/gba/
```

Dreamcast (.gdi format recommended):
```bash
scp -r ~/Downloads/"Game Folder"/* jovi@retropi.local:/home/jovi/RetroPie/roms/dreamcast/
```

---

## Step 10 - Pair 8BitDo Controller

```bash
sudo bluetoothctl
scan on
```

Turn on controller with Start + A (Android mode)
Wait for 8BitDo Pro 3 to appear then:

```bash
pair [MAC ADDRESS]
trust [MAC ADDRESS]
```

Type yes when asked to authorize service.

---

## Step 11 - Launch RetroPie

```bash
emulationstation
```

---

## Backup Procedure (Before Wiping SD Card)

Run from Mac terminal:
```bash
scp -r jovi@retropi.local:/home/jovi/RetroPie/roms/ ~/Desktop/
scp -r jovi@retropi.local:/home/jovi/.config/retroarch/saves/ ~/Desktop/
scp -r jovi@retropi.local:/home/jovi/RetroPie/BIOS/ ~/Desktop/
```

---

## Known Issues

1. VolumeControl mixer elements error in EmulationStation
   → Cosmetic only, game audio works fine, ignore it

2. Bluetooth controller disconnects
   → Run bluetoothctl and connect [MAC] after each reboot
   → trust command makes it auto-reconnect eventually

3. lr-flycast crashes without kernel8.img
   → See Step 7
