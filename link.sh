#!/bin/bash
# Link this checkout into Claude Code's user skill and agent folders.
# Re-run after every `git pull`. Safe to run twice.
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
SKILLS="$HOME/.claude/skills"
AGENTS="$HOME/.claude/agents"
mkdir -p "$SKILLS" "$AGENTS"

# Claude Code reports a skill's base directory as the link path, so every
# sibling needs its own link or the `../<name>/SKILL.md` reads fail.
link() {
  local src="$1" dst="$2"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "skip: $dst exists and is not a link" >&2
    return
  fi
  rm -f "$dst"
  ln -s "$src" "$dst"
}

for d in "$REPO"/skills/*/; do
  link "${d%/}" "$SKILLS/$(basename "$d")"
done

for f in "$REPO"/agents/*.md; do
  link "$f" "$AGENTS/$(basename "$f")"
done

# Clear links left behind by skills that upstream renamed or deleted.
for l in "$SKILLS"/* "$AGENTS"/*; do
  if [ -L "$l" ] && [ ! -e "$l" ]; then
    rm -f "$l"
  fi
done

echo "Linked $(ls -d "$REPO"/skills/*/ | wc -l | tr -d ' ') skills and $(ls "$REPO"/agents/*.md | wc -l | tr -d ' ') agents into $HOME/.claude"
