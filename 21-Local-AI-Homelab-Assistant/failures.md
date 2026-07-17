# Failures Log — Local AI Homelab Assistant

Format: Problem → Diagnosis → Fix → Prevention

---

## 1. Ollama chat responses appeared "stuck" with no output

**Problem:** Running `ollama run llama3.2:1b` and asking a question produced zero visible output for minutes at a time, with the Pi's cooling fan audibly spinning up.

**Diagnosis:** Not actually stuck — the model was genuinely thinking. The `llama3.2:1b` model still takes real CPU time to generate a response on a Pi 5 with no dedicated AI accelerator (Hailo chip not yet installed). The fan spinning up was a legitimate sign of the CPU under load, not a warning sign.

**Fix:** Confirmed via `time curl` against Ollama's raw API directly (bypassing any wrapper) that a full response genuinely takes ~30-40 seconds unstreamed on this hardware. Accepted this as the real baseline.

**Prevention:** Always test raw response time with `time` before assuming something is broken. Document expected latency per model size so future sessions don't waste time chasing a "bug" that's actually just CPU-bound inference time.

---

## 2. Repeated SSH connection drops mid-request ("Broken pipe" / "Connection reset by peer")

**Problem:** Across two separate sessions, SSH connections from Mac to Pi died mid-request over a dozen times, especially during long (30-60s) waits for AI responses. This killed whatever process was running in that terminal, making it look like Ollama or FastAPI had crashed when they hadn't.

**Diagnosis:** Root cause was unstable home internet (T-Mobile Home Internet) — not the Pi, not the code. Confirmed by the pattern: drops occurred specifically during long idle-looking waits, never during short commands.

**Fix (short-term):** Wrapped long-running processes (Ollama, Uvicorn) inside `tmux` sessions. Since tmux runs server-side on the Pi, the actual process survives even when the SSH connection carrying the output dies. Reattach with `tmux attach -t <session>` after reconnecting.

**Fix (real fix):** Upgraded home internet to Sonic fiber. Confirmed resolved — first full end-to-end test post-upgrade completed cleanly in 15.9 seconds with zero drops.

**Prevention:** Any process expected to run longer than ~10-15 seconds over SSH should be started inside `tmux` by default, regardless of connection quality, since it costs nothing and prevents this entire class of problem.

---

## 3. tmux "duplicate session" errors and accidentally killing the wrong process

**Problem:** Multiple times, trying to create a new tmux session with a name that already existed (even a dead/detached one) caused tmux to refuse and print `duplicate session: <name>`. Because the error looked similar to normal command output, subsequent commands sometimes got typed directly into an unprotected shell instead of inside tmux — and a misplaced `Ctrl+C` once killed a live Uvicorn server that was still needed.

**Diagnosis:** tmux session names persist even after being detached, and reusing a name without checking `tmux ls` first silently fails instead of erroring loudly.

**Fix:** Always run `tmux ls` before creating a new session to check for existing/stale sessions. Reattach to an existing session (`tmux attach -t <name>`) instead of creating a duplicate. When in doubt, use a fresh, never-used session name.

**Prevention:** Check `tmux ls` as a standard first step whenever starting a new work session, not just when something breaks.

---

## 4. Small model (1B) refusing to answer despite being given the correct data

**Problem:** After building a `/chat` endpoint that fed the AI real Pi temperature data, asking "what is my current cpu temperature" returned a refusal: *"I can't help with that request."* — even though the correct number was included directly in the prompt.

**Diagnosis:** Isolated the exact trigger phrase through controlled testing. The phrase "my current [X]" was being interpreted by the small 1B model as a request for live system ACCESS (like "give me permission to check my computer"), not as a simple question about a number that had already been provided. Confirmed by testing variations — removing "my current" fixed it immediately.

**Fix:** Reworded the internal prompt sent to the model to remove first-person "my current" phrasing entirely, framing it instead as a neutral third-person fact to restate: *"Raspberry Pi sensor reading: temperature = X. State this temperature reading in one short sentence."* The user's actual question can stay natural — only the internal prompt sent to the model changed.

**Prevention:** Small (1-3B parameter) instruction-tuned models are more prone to misreading ambiguous phrasing as an access/permission request. When building tool-calling prompts for small models, phrase the internal instruction as a neutral restatement of a fact rather than a first-person request, especially around system/hardware topics.

---

## 5. Pi-hole log file empty despite Pi-hole running and processing queries

**Problem:** `tail /var/log/pihole/pihole.log` returned nothing (and initially, a permission error). `pihole -c` and `pihole -t` also failed or returned deprecated-tool messages.

**Diagnosis:** Two separate issues stacked here. First, modern Pi-hole (v6+) no longer writes to that plain-text log file — it moved to a SQLite database (`pihole-FTL.db`) and deprecated the old chronometer/tail commands. Second, the reason the database showed no recent activity wasn't a bug at all — no devices on the network were actually pointed at Pi-hole as their DNS server yet, so it had nothing real to log beyond its own internal housekeeping queries.

**Fix:** Located the live database at `/etc/pihole/pihole-FTL.db` via `find`, queried it directly with `sqlite3` instead of relying on deprecated CLI tools or the stale log file. Added a narrowly-scoped `NOPASSWD` sudoers rule limited to that one exact `sqlite3` command + database path, so the FastAPI process (running as a regular user) could read it without needing a password prompt.

**Prevention:** When a "known" log file or command from documentation/tutorials doesn't behave as expected, check the actual installed version first (`pihole -v` or equivalent) — tools evolve, and older guides can reference deprecated paths/commands. When adding sudo permissions for automation, scope the rule to the exact command and file path needed, never a blanket NOPASSWD.

---

## 6. FastAPI /stats route returning "Not Found" despite being added to the code

**Problem:** After adding a new `/stats` endpoint to `app.py` and saving, `curl http://localhost:8000/stats` still returned `{"detail":"Not Found"}`.

**Diagnosis:** The file being edited was in the wrong directory. An earlier `nano app.py` had been run from the home folder (`~`) instead of `~/ollama-assistant`, creating a stray duplicate file that was never actually being served — while the real running server was still reading the original, unedited file in the correct project folder.

**Fix:** Confirmed correct working directory with `pwd`/prompt path before editing, `cat`'d the file being served by the actual running process to confirm changes were present before testing, and deleted the stray duplicate file once confirmed unnecessary.

**Prevention:** Always confirm current directory before opening a file for editing, especially mid-session when multiple terminal windows are open. `cat` the file immediately after saving to confirm the change actually landed before testing against it.
