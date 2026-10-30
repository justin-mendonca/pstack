# Setup from a bare machine

This is the path from a laptop that has never had this checkout to a working `/poteto-mode` against a GitLab repository, with tickets in Jira. Every path below assumes the clone at `~/work/pstack`. Change the path in step 2 and step 3 if you put it elsewhere.

## 0. Prerequisites

```bash
claude --version
git --version
glab auth status
jq --version
```

Claude Code installed and logged in, `glab` authenticated against the work GitLab, and `jq` present. macOS does not ship `jq`, so `brew install jq` if the last line fails.

Re-add the Jira MCP server the same way you had it, then open a session and run `/mcp` to confirm it lists. Nothing else installs. The skill scripts that needed `bun` are not part of this path.

## 1. Clone and link

```bash
git clone -b work-customizations https://github.com/justin-mendonca/pstack.git ~/work/pstack
~/work/pstack/link.sh
```

The script links every skill into `~/.claude/skills/` and both agents into `~/.claude/agents/`. Expect a line like `Linked 58 skills and 2 agents into /Users/<you>/.claude`.

Run it again after every update. It is safe to run twice, and it skips any name that already exists as a real directory.

## 2. Global instructions

```bash
cat ~/work/pstack/GLOBAL-CLAUDE.md >> ~/.claude/CLAUDE.md
```

Append rather than overwrite in case that file already has content. Then start a new session, because `CLAUDE.md` loads at session start.

If you cloned somewhere other than `~/work/pstack`, the block you appended names that path three times. Update all three.

## 3. Models

Inside Claude Code:

```
/setup-pstack
```

Pick a budget, then confirm it wrote `~/.claude/rules/pstack-models.md`. Claude Code accepts only `opus`, `sonnet`, `haiku`, and `fable`, so put opus on judgment and prose and sonnet on code if you want the review panels to differ. Grok slugs fall back to `inherit-parent`, which runs every role on your session model.

## 4. Permissions

In the work repository, not this one, at `.claude/settings.local.json`:

```json
{
  "permissions": {
    "allow": [
      "Bash(glab *)",
      "Bash(git *)",
      "Bash(jq *)",
      "Bash(gh *)",
      "mcp__jira"
    ],
    "ask": ["Bash(git push --force*)"],
    "defaultMode": "acceptEdits"
  }
}
```

Use `settings.local.json` rather than `settings.json`. The plain name is committed and shared, and your agent's permissions are yours. Replace the `mcp__jira` entry with the real prefix once `/mcp` shows it.

Skip `bypassPermissions`. It is the setting your admin most likely disables, and it is not needed once the allow list covers the commands a run uses.

## 5. A verification skill, per repository

pstack proves changes on the real artifact, and it can only do that if the repository states how. In the work repository at `.claude/skills/verify/SKILL.md`:

```markdown
---
name: verify
description: Prove a change works in this repo.
---

Build: `<command>`
Test: `<command>`

For any change that alters behavior, also run the end-to-end check:
`<command that exercises the real path>`.
It passes when `<the output or assertion you look for>`.

Never report a change as verified on the build or unit tests alone.
```

The last line carries the weight. Without it the agent reports "verified" off a green test run, and the Prove It Works step has nothing real behind it.

## 6. First ticket

In the work repository, on a small low-risk ticket:

```
/poteto-mode <paste the ticket, or the Jira key plus one line on what done means>
```

What to expect. It reads the Claude Code adapter, matches a playbook, opens a todo list with that playbook's steps copied in, investigates with `how`, then plans. Implementation goes to subagents in worktrees. It commits small units and ends by opening a merge request through `glab` and commenting the link on the ticket. It stops at merge-ready.

Watch these on the first run:

- A `gh` command. The remote is not resolving as GitLab. Check `git remote get-url origin`.
- A stall on a permission prompt. A rule is missing from step 4.
- A merge request against the wrong branch. The playbooks say "trunk", and yours may be `develop` or something else.

Merge by hand for the first two or three tickets. Only then put `glab mr merge` in the allow list.

## Updating

```bash
cd ~/work/pstack
git pull
git merge origin/main
./link.sh
```

`git pull` takes your own pushes from another machine, since the clone set the branch upstream to `origin/work-customizations`. The merge takes upstream pstack through the mirror, which `git pull` never brings because main is not this branch's upstream. Then relink, because a skill upstream added has no link yet.

Do not point the branch upstream at `origin/main` to save the second command. A bare `git push` would then default to main.

## When something goes wrong

- A merge conflict on update. It will be in one of the four edited playbook lines. Keep upstream's new wording and put your line back.
- A skill reads as missing after an update. `link.sh` was not rerun.
- The agent stops behaving like poteto mode partway through. The mode is manual-invocation only, so a compaction can drop it. The global block in step 2 tells it to reread `~/.claude/skills/poteto-mode/SKILL.md`, which only works if that block is installed and the session was started after it.
- A step tries the Skill tool and gets a refusal for a pstack skill. Same cause. Most pstack skills are manual-invocation only, and the global block is what tells the agent to read their `SKILL.md` directly instead.
- A pstack step needs a Cursor-only feature such as Bugbot or an automation. It should print `Skipped in Claude Code: <step>. <reason>.` and continue. If it stops instead, the adapter in `docs/harness/claude-code.md` was not read.
