# RAID 1 Build — Failures & Recovery Log

Multi-day recovery saga. Six distinct incidents, chained together, 
each with real root cause and fix. This is the boss fight.

---

## Update — Hub-Boot Rule Revisited
**Date:** July 2026
Original Incident 1 rule stated boot drives must never go through a USB 
hub. Since then, the T7 has been reliably power-cycling through the 
SABRENT hub for multiple weeks with zero enumeration failures. The 
original failure appears to have been specific to that RAID recovery 
moment, not a hard hub-boot incompatibility. Rule downgraded from 
"permanent" to "watch for it if issues resurface."

---

## Incident 1 — USB Hub Enumeration Failure (Bootloader Level)

**Problem:** After the initial RAID array build, the T7 boot drive was 
moved onto the SABRENT powered hub alongside the WD Elements drives. 
On next boot, the Pi showed zero HDMI output — fans spinning, no video 
at all, not even the rainbow splash screen.

**Diagnosis:** Pulled the Pi's bootloader diagnostic screen directly 
(no OS involved yet) and found:
MSD READ_CAPACITY [08:06] 3.32 000344:03 lun 0 block-count 0 block-size 512
BOOT ERROR: code 45 - 'Fatal firmware error'
`block-count 0` meant the Pi's bootloader could see the T7 on the USB 
bus but couldn't read its actual capacity. This is a known Pi quirk — 
the earliest-stage USB driver used at boot doesn't reliably enumerate 
storage through a hub, even a good powered one. Confirmed by testing: 
plugged T7 directly into the Pi's own USB port, bootloader read it fine.

**Fix:** Boot drive (T7) moved permanently to the Pi's own direct USB 
port. WD Elements RAID pair stayed on the SABRENT hub — they're not 
boot devices, so hub enumeration doesn't apply to them.

**Prevention:** **New permanent rule — boot drive (T7) always direct 
into the Pi's own USB port, never through any hub.** Confirmed twice 
across this saga (once at bootloader level, once later mistaken for 
drive corruption).

📸 `raid1-bootloader-block-count-zero-error.png`
📸 `raid1-bootloader-fatal-firmware-error.png`

---

## Incident 2 — Twice-Interrupted fsck Causing Real Filesystem Corruption

**Problem:** Mid-migration, the Pi was power-cycled twice while `fsck` 
was actively running on the T7's root partition (interrupted to leave 
the house). On next boot: complete black screen, fans running nonstop, 
no video output at all — not even the initial GPU splash.

**Diagnosis:** Pulled the direct-boot diagnostic screen and watched a 
real `fsck` recovery run:
rootfs: recovering journal
rootfs primary superblock features different from backup, check forced.
rootfs: ***** FILE SYSTEM WAS MODIFIED *****
Confirmed real corruption had occurred from the repeated power loss 
during active disk writes — not a dead drive, an actual damaged 
filesystem that needed automated repair.

**Fix:** Let `fsck` complete a full, uninterrupted pass this time. 
It found and repaired the damage automatically, then handed off to a 
bare `root@(none):/#` shell via the `init=/bin/bash` boot flag.

**Prevention:** **Never power-cycle mid-fsck or mid-resync, no exceptions.** 
Interrupting disk-repair operations is what caused this in the first 
place — every additional interruption made the eventual repair take 
longer, not shorter.

📸 `raid1-fsck-recovering-journal-fs-modified.png`

---

## Incident 3 — Stale fstab UUID Blocking Boot (Emergency Mode)

**Problem:** After WD1 got wiped and folded into the RAID array, the 
Pi would boot partway then drop into emergency mode:
[TIME] Timed out waiting for device dev-disk-by-uuid-3fcbc3d7...
[DEPEND] Dependency failed for mnt-wdelements.mount
You are in emergency mode.
Cannot open access to console, the root account is locked.

**Diagnosis:** `/etc/fstab` still referenced WD1's **old** standalone 
ext4 filesystem UUID. That filesystem stopped existing the moment WD1 
was wiped to join the RAID array — but fstab never got updated, so 
systemd kept trying (and failing) to mount a UUID that no longer existed, 
and treated the failure as fatal since the line had no `nofail`.

**Fix:** Booted via `init=/bin/bash` (added to `cmdline.txt` on the FAT32 
boot partition, edited directly from the Mac since it's not ext4), 
remounted root read-write, edited fstab to add `nofail` to the line, 
then swapped the dead UUID for the RAID array's real filesystem UUID 
once it existed.

**Prevention:** **Any fstab line referencing removable/RAID-member drives 
gets `nofail` from now on.** A failed non-critical mount should degrade 
the boot, not block it entirely.

📸 `raid1-emergency-mode-root-locked.png`

---

## Incident 4 — RAID Array Stuck in Auto-Read-Only, Resync Not Resuming

**Problem:** After a reboot, the array reassembled on its own but sat 
in `active (auto-read-only)` with no resync progress and no `recovery = X%` 
line — looked stalled.

**Diagnosis:**
```bash
cat /proc/mdstat
md127 : active (auto-read-only) raid1 sdb1[1] sdc1[2]
```
This is mdadm's safety default — auto-assembled arrays stay locked 
read-only until something explicitly writes to them, specifically to 
prevent the kernel from touching a freshly-reassembled array before 
it's confirmed healthy.

**Fix:**
```bash
sudo mdadm --readwrite /dev/md127
```
Resync resumed immediately from the bitmap-tracked percentage — not 
from zero.

**Prevention:** After any reboot mid-resync, always check `auto-read-only` 
state and bump it manually. This isn't a bug, it's expected mdadm behavior 
worth knowing.

📸 `raid1-auto-read-only-readwrite-fix.png`

---

## Incident 5 — Array Assembling as `md127` Instead of `md0`

**Problem:** The array kept reassembling under a different device name 
(`md127`) on different boots, instead of a consistent `md0`.

**Diagnosis:** The array was never registered in `/etc/mdadm/mdadm.conf`, 
so the kernel had no persistent name mapping — it just assigned whatever 
number was next available at boot time.

**Fix:**
```bash
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
sudo update-initramfs -u
```

**Prevention:** The numeric name (`md0` vs `md127`) turned out to not 
actually matter functionally — mdadm creates a persistent symlink 
(`/dev/md/retropi:0`) that always resolves correctly regardless of the 
numeric name. Real lesson: **never hardcode `/dev/md0` in configs — 
always use the persistent name-based path or filesystem UUID.**

📸 `raid1-mdadm-conf-registered-resync-resumed.png`

---

## Incident 6 — Stale Docker Bind Mounts After RAID Migration

**Problem:** After fixing the RAID mount, new qBittorrent downloads and 
Jellyfin's view of the library still appeared to reference the wrong 
underlying storage — turned out to be containers holding onto bind 
mounts established before the RAID array was properly attached.

**Diagnosis:** Docker bind-mounts a host folder at container start time. 
Since these containers had been started/restarted multiple times 
throughout the migration (before the RAID mount was consistently in 
place), some retained stale references to whatever was underneath 
`/mnt/wdelements` at that particular boot — sometimes the T7 root 
drive, sometimes the array.

**Fix:**
```bash
cd ~/docker/qbittorrent && docker compose down && docker compose up -d
cd ~/docker/jellyfin && docker compose down && docker compose up -d
```
`down`/`up -d` forces a full container recreate, re-establishing the 
bind mount against whatever's actually mounted right now — `restart` 
alone doesn't do this.

**Prevention:** After any change to what's mounted at a path used by 
Docker volumes, fully recreate affected containers (`down`/`up`), don't 
just restart them.

📸 `raid1-recovery-cloudflared-containers-restored.png`

---

## Final State
md127 : active raid1 sdc1[2] sdb1[1]
5860355072 blocks super 1.2 [2/2] [UU]
State: clean
Both drives fully synced, RAID 1 mirror live and healthy.

**Resume line:** *"Recovered a multi-drive RAID 1 array through six 
distinct real-world failures — USB enumeration bugs, filesystem 
corruption from unclean shutdowns, stale boot configs, and stale 
container mounts — diagnosing and resolving each at the appropriate 
layer of the stack from bootloader to container runtime."*