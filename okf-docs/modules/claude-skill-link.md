---
type: SeihouModule
title: claude-skill-link
description: Declare a manifest-owned checkout link from claude/skills/ into .claude/skills/
resource: seihou://agent-seihou/modules/claude-skill-link
tags:
- claude
- skill
- infrastructure
status: stable
generated:
  by: seihou-okf-extension/0.10.0.0
version: 0.2.0
---

# claude-skill-link

Declare a manifest-owned checkout link from claude/skills/ into .claude/skills/

**Version:** 0.2.0

## Dependencies

- [claude-gitignore](/modules/claude-gitignore.md)

## Variables

- `skill.name` — text, required, matching `[a-z][a-z0-9-]*`. Name of the skill directory (e.g. rei-update-docs)

## Exports

No exports declared.

## Prompts

- `skill.name` — What is the skill directory name?

## Generation steps

- `Symlink` `claude/skills/{{skill.name}}` → `.claude/skills/{{skill.name}}`
