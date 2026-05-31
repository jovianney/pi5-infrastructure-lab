# Security Camera System 📷

## What I Built
Deployed a self-hosted IP security camera system using a Reolink Lumus outdoor camera, MotionEye NVR software, and a custom Python alert script — all running on the Raspberry Pi 5 with remote viewing via Tailscale VPN.

No cloud. No subscription. No third party storing my footage.

---

## Hardware
| Component | Details |
|---|---|
| Camera | Reolink Lumus 2K Outdoor WiFi Camera |
| Protocol | RTSP stream over local network |
| Server | Raspberry Pi 5 8GB |
| Storage | Samsung T7 1TB SSD |

---

## Software Stack
| Software | Purpose |
|---|---|
| MotionEye 0.43.1 | Web dashboard, motion detection, recording |
| Motion 4.7.1 | Motion detection engine |
| Python 3 | Custom email alert script |
| Tailscale | Secure remote access from anywhere |
| UFW | Firewall — port 8765 opened for dashboard |
| Gmail SMTP | Alert delivery via app password |

---

## What This Does
- Streams live 2K video feed accessible via web dashboard
- Detects motion and triggers recording automatically
- Sends email alert with timestamp when motion detected
- Remote viewing from anywhere via Tailscale VPN
- Footage stored locally on Pi — no cloud dependency

---

## How It Works
Reolink Camera → RTSP Stream → MotionEye on Pi
↓
Motion Detected
↓
Python Script Fires
↓
Email Alert → jovianney@ymail.com
↓
Footage Saved Locally on T7 SSD

---

## Key Configuration
- Camera static IP: `192.168.12.177`
- RTSP URL: `rtsp://admin:***@192.168.12.177:554/h264Preview_01_main`
- MotionEye dashboard: `http://192.168.12.240:8765`
- Remote access: `http://100.121.71.88:8765` (via Tailscale)
- UFW rule: `sudo ufw allow 8765/tcp`

---

## Screenshots

### MotionEye Login
![MotionEye Login](screenshots/MotionEye-Login.png)

### MotionEye Dashboard
![MotionEye Dashboard](screenshots/MotionEye-Dashboard.png)

### Live Camera Feed
![Live Feed](screenshots/MotionEye-Live-Feed.png)

### MotionEye Service Running
![Service Running](screenshots/MotionEye-Service-Running.png)

### Python Alert Script
![Python Script](screenshots/Python-Alert-Script.png)

### Motion Alert Email
![Motion Alert](screenshots/Motion-Alert-Email.png)

### RTSP Stream Verified
![RTSP Verified](screenshots/RTSP-Stream-Verified.png)

---

## Python Alert Script
Motion triggers MotionEye to run `/home/jovi/motion_alert.py` which sends an email via Gmail SMTP to Yahoo Mail.

See `failures.md` for all errors encountered during this build.

---

## Skills Demonstrated
- IP camera configuration and network integration
- RTSP stream verification and troubleshooting
- Linux service management (systemctl)
- Python scripting for automated alerts
- Email delivery via SMTP
- Firewall configuration (UFW)
- Docker architecture troubleshooting (amd64 vs arm64)
- Remote access via VPN

---

## Resume Line
"Built self-hosted surveillance system with IP camera, motion detection, automated email alerts, and remote VPN monitoring — no cloud dependency"

---

## Future Upgrade — Boss Level 🔥
Phase 2: Swap MotionEye for Frigate NVR + add Coral TPU USB for local AI object detection (person/vehicle/animal recognition). Same Reolink camera, completely upgraded brain.