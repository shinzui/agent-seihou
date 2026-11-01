---
type: SeihouModule
title: link-skill
description: Declare manifest-owned checkout links from agents/skills/ into .claude/skills/,
  .codex/skills/ and .agents/skills/
resource: seihou://agent-seihou/modules/link-skill
tags:
- claude
- agents
- skill
- infrastructure
status: stable
generated:
  by: seihou-okf-extension/0.14.0.0
version: 0.4.0
---

# link-skill

Declare manifest-owned checkout links from agents/skills/ into .claude/skills/, .codex/skills/ and .agents/skills/

**Version:** 0.4.0

## Dependencies

- [claude-gitignore](/modules/claude-gitignore.md)

## Variables

- `skill.name` — text, required, matching `[a-z][a-z0-9-]*`. Name of the skill directory (e.g. rei-update-docs)

## Exports

No exports declared.

## Prompts

- `skill.name` — What is the skill directory name?

## Generation steps

- `Template` `gitignore.tpl` → `.gitignore` (appends one line to a file another module owns, if absent)
- `Symlink` `agents/skills/{{skill.name}}` → `.claude/skills/{{skill.name}}`
- `Symlink` `agents/skills/{{skill.name}}` → `.agents/skills/{{skill.name}}`
- `Symlink` `agents/skills/{{skill.name}}` → `.codex/skills/{{skill.name}}`
