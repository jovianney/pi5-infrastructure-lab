# Linux Command Cheat Sheet
*Real commands, plain English explanations — built during hands-on homelab experience.*

---

## Navigation
| Command | What it does |
|---|---|
| `pwd` | Shows where you are right now |
| `ls` | Lists files and folders in current directory |
| `ls -la` | Lists everything including hidden files + permissions |
| `cd foldername` | Move into a folder |
| `cd ..` | Go back one folder |
| `cd ~` | Go straight to home directory |

---

## File Management
| Command | What it does |
|---|---|
| `cp file1 file2` | Copy a file |
| `mv file1 file2` | Move or rename a file |
| `rm filename` | Delete a file |
| `rm -rf foldername` | Delete a folder and everything in it (careful) |
| `mkdir foldername` | Create a new folder |
| `touch filename` | Create an empty file |
| `cat filename` | Print file contents to screen |
| `nano filename` | Open file in text editor |

---

## Permissions
| Command | What it does |
|---|---|
| `chmod 755 file` | Set read/write/execute permissions |
| `chown user file` | Change who owns a file |
| `ls -la` | See permissions on all files |

---

## System Monitoring
| Command | What it does |
|---|---|
| `top` | Live view of CPU and memory usage |
| `htop` | Prettier version of top |
| `df -h` | Check disk space |
| `free -h` | Check RAM usage |
| `uptime` | How long system has been running |

---

## Services & Processes
| Command | What it does |
|---|---|
| `systemctl status servicename` | Check if a service is running |
| `systemctl start servicename` | Start a service |
| `systemctl stop servicename` | Stop a service |
| `systemctl restart servicename` | Restart a service |
| `systemctl enable servicename` | Auto-start service on boot |
| `ps aux` | See all running processes |
| `kill PID` | Stop a process by its ID |

---

## Networking
| Command | What it does |
|---|---|
| `ping google.com` | Test network connectivity |
| `ip a` | Show IP addresses |
| `ssh user@ip` | Connect to remote machine |
| `scp file user@ip:/path` | Copy file to remote machine |
| `curl ifconfig.me` | Show your public IP |

---

## Logs
| Command | What it does |
|---|---|
| `journalctl -xe` | View system logs |
| `journalctl -u servicename` | Logs for a specific service |
| `tail -f /var/log/syslog` | Watch logs in real time |

---

## SSH
| Command | What it does |
|---|---|
| `ssh user@ip` | Connect to remote machine |
| `ssh jovi@192.168.12.239` | Example — connect to Pi by IP |
| `ssh jovi@retropi.local` | Connect to Pi by hostname |
| `ssh-keygen -R 192.168.12.239` | Fix "host key changed" warning after reflash |
| `exit` | Disconnect from SSH session |

---

## File Transfers (SCP)
| Command | What it does |
|---|---|
| `scp file.txt user@ip:/destination/` | Copy file from Mac to remote machine |
| `scp jovi@192.168.12.240:~/file .` | Copy file FROM remote machine to current folder |

---

## Git
| Command | What it does |
|---|---|
| `git clone url` | Download a repo locally |
| `git add .` | Stage all changes |
| `git commit -m "message"` | Save changes with a description |
| `git push` | Upload to GitHub |
| `git pull` | Pull latest changes from GitHub |

---

*Built by Jovianney De La Cruz — pi5-infrastructure-lab*ok 

