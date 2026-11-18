#!/usr/bin/env bash
# story-branch.sh — make sure a branch for a user story exists and is checked out.
#
# Usage: ./scripts/story-branch.sh <STORY_ID> <slug>
#   e.g. ./scripts/story-branch.sh US-12 login-form
#
# Behavior:
#   - fetches origin (warns and continues on local refs if offline)
#   - if a branch story/<id>-* already exists locally or on origin, checks it out
#   - otherwise creates story/<id>-<slug> from the latest origin/main
set -euo pipefail

id="${1:?usage: ./scripts/story-branch.sh <STORY_ID> <slug>}"
slug="${2:?usage: ./scripts/story-branch.sh <STORY_ID> <slug>}"

norm() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]._-'; }
id="$(norm "$id")"
slug="$(norm "$slug")"
prefix="story/${id}"

git fetch origin --prune 2>/dev/null || echo "warning: git fetch failed (offline?) - using local refs only" >&2

# Prefer the exact branch for this slug, then any existing branch of this story.
existing=""
for candidate in "$prefix-$slug" $(
  { git branch --list "$prefix-*"; git branch -r --list "origin/$prefix-*"; } \
    | sed -e 's/^[* ]*//' -e 's|^origin/||' | sort -u
); do
  if git show-ref --verify --quiet "refs/heads/$candidate" \
     || git show-ref --verify --quiet "refs/remotes/origin/$candidate"; then
    existing="$candidate"
    break
  fi
done

if [ -n "$existing" ]; then
  # DWIM: creates a local tracking branch when only the remote branch exists.
  git switch "$existing"
else
  base="origin/main"
  git show-ref --verify --quiet "refs/remotes/origin/main" || base="main"
  git switch -c "$prefix-$slug" "$base"
fi

echo "story branch: $(git branch --show-current)"
