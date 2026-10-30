# Global Claude Code instructions for pstack

Paste this file into `~/.claude/CLAUDE.md` on the work laptop after cloning and running `link.sh`. Paths assume the checkout at `~/work/pstack`. Change them if you cloned elsewhere.

## pstack

- Run work that comes from a ticket in poteto mode. Read `~/.claude/skills/poteto-mode/SKILL.md` in full and follow it, and stay in it for the whole task, including after a compaction. If the mode body is no longer in context, read the file again before your next step.
- Most pstack skills are manual-invocation only, so the Skill tool refuses them. When a step routes to one, read `~/.claude/skills/<name>/SKILL.md` directly and follow it. A read-and-followed skill counts as the skill having run.
- Read `~/work/pstack/docs/harness/claude-code.md` once per session before following a pstack skill. It maps Cursor tool and field names to Claude Code's.

## Forge

- Read the remote to resolve the forge. A GitLab host means `glab`, and `~/work/pstack/skills/poteto-mode/references/gitlab.md` replaces every `gh pr` and `origin pr` command in the playbooks.
- Never fall back to `gh` on a GitLab remote. Say which command you needed instead.

## Tickets

- Ticket context comes from Jira through the Jira MCP tools. Read the issue and its comments before planning, and treat the description as the spec.
- Post the merge request link to the ticket as a comment when it opens, and post again with the pipeline result.
- Ticket writes are reversible, so they need no approval.

## Autonomy

- Do reversible work without asking and report it afterwards.
- Pause for a force-push to a shared branch, a deploy, data deletion, a customer message, and a merge to a protected branch.
- When a permission rule blocks a command you need, name the rule to add instead of working around it.

## Writing

- Replies follow the rules in `~/.claude/skills/unslop/SKILL.md`. Read it once, then write clean as you go: short declarative sentences, no long dashes, no chatbot filler, plain words over jargon.
- Name each pstack principle that changed a decision, and cite only the ones whose `SKILL.md` you read this session.
