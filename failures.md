# Failures & Troubleshooting Log

## Issue 1: No SD card slot on MacBook
**Date:** May 9, 2026  
**Problem:** Could not flash SD card directly 
from MacBook — no built-in SD card slot  
**Fix:** Purchased USB-C hub with SD card reader  
**Lesson:** Always check hardware compatibility 
before starting a deployment

## Issue 2: Hotspot connection failed (April 2026)
**Date:** April 5, 2026  
**Problem:** Pi configured with iPhone hotspot 
(iPhonezilla) — hotspot was unreliable and Pi 
could not maintain connection  
**Fix:** Reflashed SD card with stable home WiFi 
credentials  
**Lesson:** Use stable networks for first boot. 
Hotspots are unreliable for server deployments

## Issue 3: No power outlet at coffee shop
**Date:** April 5, 2026  
**Problem:** Attempted first boot at coffee shop 
with no available power outlet  
**Fix:** Used Anker Solix C200 portable power 
station via USB-C to power Pi 5  
**Lesson:** Pi 5 only needs 27W — any quality 
power bank works for field deployments

## Issue 4: SSH permission denied (wrong password)
**Date:** May 9, 2026  
**Problem:** SSH connection found Pi but returned 
permission denied on first two attempts  
**Fix:** Entered correct password on third attempt 
(password not visible when typing — normal behavior)  
**Lesson:** SSH passwords are hidden while typing. 
This is a security feature not a bug

## Issue 5: T-Mobile router DNS locked down
**Date:** May 9, 2026  
**Problem:** T-Mobile KVD21 gateway does not allow 
DNS configuration through browser interface — 
requires mobile app which also lacks DNS settings  
**Fix:** Manually configured DNS on each device 
individually (MacBook and mobile devices)  
**Lesson:** ISP routers are often locked down. 
Device-level DNS configuration is a reliable workaround
