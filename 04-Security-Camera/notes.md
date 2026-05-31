What is failures.md?
It's a log of every time something broke and how I fixed it. Instead of hiding mistakes I document them. That's what separates junior candidates from people who actually know what they're doing. Employers love this because it shows you can troubleshoot, not just follow tutorials.
Failure 001 — Log permissions
MotionEye tried to write its logs to /var/log but didn't have permission. Like trying to write in someone else's notebook. I created a folder specifically for MotionEye and gave it ownership of that folder.
Failure 002 — UFW blocking the dashboard
UFW is my firewall. It blocks everything by default unless I specifically allow it. Port 8765 is where MotionEye lives but the firewall didn't know that. I told the firewall to let traffic through on that port.
Failure 003 — Wrong Docker architecture
Like trying to install a Windows app on a Mac. The Docker image I downloaded was built for Intel processors but the Pi uses ARM. I ditched Docker entirely and installed MotionEye directly instead.
Failure 004 — Codec not found
A codec is basically a video compression format. The Pi 5 doesn't support the hardware video encoder I selected. I switched to a software encoder that works on any hardware.
Failure 005 — RTSP toggle glitch
The Reolink app had a hiccup on the first try. Second attempt worked fine. Documented it anyway because it caused confusion and wasted time.