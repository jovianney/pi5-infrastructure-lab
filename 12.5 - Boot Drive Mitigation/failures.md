## Backup Script Shebang Corruption

**Problem:** Rewritten backup.sh failed to have a valid shebang line — 
`cat` revealed `k#!/bin/bash` instead of `#!/bin/bash`.

**Diagnosis:** Stray keystroke during nano edit landed before the shebang, 
likely from an incomplete "select all + delete" before pasting new content.

**Fix:** Reopened the file in nano, removed the single stray character, 
re-verified with `cat` before running.

**Prevention:** This is exactly why the standing rule is "always `cat` a 
file after editing to confirm the change saved" — nano edits over SSH 
can silently introduce single-character errors that are easy to miss at 
a glance but would have broken the script on its first scheduled run.