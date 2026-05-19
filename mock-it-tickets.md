# Mock IT Tickets

## Ticket #001 — User Cannot Connect to WiFi

**Device:** Windows laptop  
**Priority:** High

### Diagnosis
1. Asked user if other devices on same network work
   - Yes, other devices connecting fine
   - Problem isolated to THIS device, not the router

2. Checked if WiFi is enabled on the laptop
   - WiFi toggle was on
   - Could see the network name but couldn't connect

3. Ran ipconfig in Command Prompt
   - IP address showed 169.254.x.x (APIPA address)
   - This means DHCP failed — device couldn't get
     an IP address from the router

4. Checked if IP was manually set
   - Found static IP was set from a previous config
   - Conflicting with the network's DHCP range

### Fix
- Changed network settings back to "Obtain IP address automatically"
- Ran ipconfig /release then ipconfig /renew
- Device received valid IP: 192.168.1.45
- WiFi connection restored ✅

### Prevention
- Never manually set IP unless you know the network
- If 169.x.x.x shows up = always suspect DHCP first
- Document any static IP configs for future reference

---

## Ticket #002 — Laptop Extremely Slow

**Device:** MacBook Pro, 3 years old  
**Priority:** Medium

### Diagnosis
1. Asked user when it started
   - Started after installing new software yesterday

2. Checked CPU and Memory usage
   - Opened Activity Monitor
   - One process using 94% CPU continuously
   - Identified as a background sync app gone rogue

3. Checked storage space
   - Only 2GB free out of 256GB
   - Low storage causes system to use hard drive
     as RAM (virtual memory) = major slowdown

4. Checked startup items
   - 12 apps set to launch at startup
   - All running in background eating resources

### Fix
- Force quit the rogue process in Activity Monitor
- Deleted old files and emptied trash → freed 40GB
- Removed unnecessary startup items
- Restarted laptop
- Performance back to normal ✅

### Prevention
- Keep at least 15% storage free at all times
- Audit startup programs every few months
- Monitor Activity Monitor if slowness returns

---

## Ticket #003 — User Cannot Access Shared Drive

**Device:** Windows 10 desktop  
**Priority:** High

### Diagnosis
1. Asked if they could access it before
   - Yes, was working fine until this morning

2. Checked if other users had the same issue
   - No, only this user affected
   - Rules out server being down

3. Checked network connectivity
   - Ran ping 192.168.1.100 (file server IP)
   - Ping successful = network is fine
   - Problem is permissions or credentials, not network

4. Checked user account status
   - User's network password expired overnight
   - Windows cached old credentials
   - Was silently failing authentication to the server

### Fix
- Had user update their network password
- Cleared cached credentials in Windows Credential Manager
- Mapped the shared drive again with new credentials
- Access restored ✅

### Prevention
- Set up password expiration notifications
  so users get warned 7 days before
- Document server IP addresses for quick ping tests
- Check Credential Manager first when shared
  drive access suddenly breaks