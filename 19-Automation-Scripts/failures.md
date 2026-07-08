# Failures — Self-Healing Automation Script

## Incident 1: Script created with wrong file ownership

**What broke:** `chmod +x` and running the script both failed with 
"Operation not permitted" / "Permission denied."

**Root cause:** The script file was created using `sudo nano`, which made 
root the file owner. My regular user (`jovi`) had no permission to modify 
or execute it.

**Fix:** `sudo chown jovi:jovi self-healing.sh` to hand ownership back to my 
own user, then `chmod +x` worked normally.

**Lesson:** Be consistent about which user creates a file versus which user 
needs to use it day-to-day. `sudo` for file creation isn't free — it changes 
ownership too.

## Incident 2: Container names guessed instead of verified

**What broke:** Script reported `sparkyfitness` and `motioneye` as "down" 
and failed to restart them — repeatedly, every run.

**Root cause:** Assumed Docker container names would match the service 
name. In reality, docker-compose prefixes container names with the project 
folder (SparkyFitness runs as three separate containers), and MotionEye 
isn't Docker at all — it's the native `motion` systemd service.

**Fix:** Ran `docker ps -a --format "table {{.Names}}\t{{.Status}}"` to get 
ground truth on actual container names, updated the script's arrays to 
match exactly, and moved `motion` into the systemd services array instead 
of the Docker containers array.

**Lesson:** Never assume naming conventions — always verify against the 
actual running system before writing automation against it.

## Incident 3: Log file permission conflict

**What broke:** `self-healing.log` was created during an earlier `sudo` 
test run, so it ended up root-owned. Running the script afterward as a 
regular user threw "Permission denied" trying to write to that same log.

**Fix:** Deleted the root-owned log (`sudo rm`) and let the script recreate 
it under the correct user on the next run.

**Lesson:** Same root cause as Incident 1 — mixing `sudo` and non-sudo runs 
of the same script creates ownership conflicts on any files it touches, not 
just the script itself.

## Incident 4: Postfix installed but not actually running

**What broke:** `mail -s` command in the script produced no visible error, 
but no email ever arrived. `mailq` revealed the real issue: 
"mail system is down (Connection refused)."

**Root cause:** Postfix was installed on the system but the service itself 
was never running — and even if it were, default Postfix only handles 
local mail delivery, not relaying to external providers like Gmail or 
Yahoo without additional relay configuration.

**Fix:** Installed `msmtp` instead of fighting Postfix's relay config. 
Configured it with Gmail SMTP credentials (using a Google App Password, not 
the real account password) in `~/.msmtprc`, then pointed the system `mail` 
command at msmtp via `/etc/mail.rc`'s `sendmail` setting — so the existing 
script's `mail -s` calls worked without any script changes.

**Lesson:** A package being installed doesn't mean it's configured or 
running. Always verify service status (`systemctl status`, `mailq`, etc.) 
rather than assuming "installed" means "working."

## Incident 5: Config file permission mismatch (msmtp)

**What broke:** After correctly saving `/etc/msmtprc` with `chmod 600`, 
msmtp still failed: "account default not found: no configuration file 
available."

**Root cause:** `chmod 600` combined with root ownership (from `sudo nano`) 
meant only root could read the file. Testing as a regular user, msmtp 
couldn't see the config at all.

**Fix:** Copied the config to `~/.msmtprc` instead, owned by my own user, 
with the same `600` permissions — msmtp checks the user's home directory 
config before falling back to the system-wide one.

**Lesson:** `600` permissions plus wrong ownership silently locks you out 
of your own file. Permission mode and file ownership have to be checked 
together, not independently.

## Incident 6: Raw piped email missing headers

**What broke:** First msmtp test technically sent (Gmail confirmed 
`250 OK`), but the email arrived with no `To:`, `From:`, or `Subject:` — 
just raw body text.

**Root cause:** `echo "text" | msmtp address` sends plain text with zero 
email headers attached — msmtp doesn't add them automatically.

**Fix:** Rebuilt the test using `printf` to manually construct proper 
headers (`To:`, `From:`, `Subject:`, blank line, body), piped into 
`msmtp -t` so it reads the recipient from the headers themselves.

**Lesson:** A successful send confirmation from the mail server doesn't 
mean the message is well-formed. Headers matter for both deliverability 
and spam filtering — always test with realistic message structure.

## Note: New sender flagged as spam

First few properly-formatted test emails landed in spam on the receiving 
end (ymail), not because of a config error, but because a new 
sender/pattern (homelab → Gmail relay → ymail) has no trust history yet 
with the receiving provider's spam filter. Marked as "not spam" to begin 
building sender trust.