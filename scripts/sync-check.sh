#!/usr/bin/env bash
# sync-check.sh — run at the start of EVERY turn, before any other work.
#
# 1. Always updates lastWorkedTimestamp.txt (repo root, gitignored) with the
#    current time, so every user prompt is recorded.
# 2. If the previous prompt was more than 2h ago (new session after a break,
#    or the same session after inactivity), it syncs with origin FIRST:
#      - on main:            git pull --ff-only
#      - on a story branch:  git merge origin/main --no-edit
#    so work never starts on stale state and merge issues surface early.
set -euo pipefail

STAMP="lastWorkedTimestamp.txt"
STALE_AFTER=7200  # 2 hours, in seconds

now="$(date -u +%s)"
old="0"
if [ -f "$STAMP" ]; then
  old="$(cat "$STAMP" 2>/dev/null || echo 0)"
fi
case "$old" in ''|*[!0-9]*) old="0" ;; esac
printf '%s\n' "$now" > "$STAMP"

if [ "$old" -gt 0 ] && [ $((now - old)) -gt "$STALE_AFTER" ]; then
  echo "sync-check: last prompt was $(( (now - old) / 60 )) min ago (> 2h) - syncing with origin first"
  git fetch origin --prune
  branch="$(git branch --show-current)"
  if [ "$branch" = "main" ]; then
    git pull --ff-only
  else
    git merge origin/main --no-edit
  fi
  echo "sync-check: synced, now on branch '$branch'"
else
  echo "sync-check: $STAMP updated (no pull needed)"
fi
