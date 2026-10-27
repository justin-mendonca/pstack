#!/bin/bash
REPO="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO" || exit 1
git fetch origin
git switch -C work-customizations origin/work-customizations
ln -sfn "$REPO"/skills/*/ ~/.claude/skills/
ln -sfn "$REPO"/agents/*.md ~/.claude/agents/
