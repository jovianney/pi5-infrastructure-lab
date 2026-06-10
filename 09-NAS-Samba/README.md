# 09 — NAS File Server (Samba)

Self-hosted network-attached storage using Samba on Raspberry Pi 5.
Accessible from Mac via SMB protocol with role-based access controls.

## What Was Built
- Samba file server running on Raspberry Pi OS
- 3 shared folders: Media, Backups, Documents
- Role-based access: admin user (read/write) and guest user (read-only)
- Accessible from MacBook via Finder (Cmd+K → smb://192.168.12.239)

## Shares Configured

| Share | User | Access |
|-------|------|--------|
| Media | jovi | Read/Write |
| Backups | jovi | Read/Write |
| Documents | jovi | Read/Write |
| GuestShare | guest01 | Read Only |

## Skills Demonstrated
- Linux package installation and service management
- Samba configuration and SMB file sharing
- User creation and permission management
- UFW firewall rules for service access
- Principle of Least Privilege implementation

## Resume Line
"Deployed network-attached storage with role-based access controls using Samba on Linux"

## Note
OMV was attempted first but conflicted with Tailscale network stack.
Recovered and switched to Samba — see 08-Broken-Lab-Category/failures.md Incident 005.
