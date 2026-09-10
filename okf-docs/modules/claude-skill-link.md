---
type: SeihouModule
title: claude-skill-link
description: Symlink a Claude skill from claude/skills/ into .claude/skills/
resource: seihou://agent-seihou/modules/claude-skill-link
tags:
- claude
- skill
- infrastructure
status: stable
generated:
  by: seihou-okf-extension/0.8.0.0
version: 0.1.0
---

# claude-skill-link

Symlink a Claude skill from claude/skills/ into .claude/skills/

**Version:** 0.1.0

## Dependencies

- [claude-gitignore](/modules/claude-gitignore.md)

## Variables

- `skill.name` — text, required, matching `[a-z][a-z0-9-]*`. Name of the skill directory (e.g. rei-update-docs)

## Exports

No exports declared.

## Prompts

- `skill.name` — What is the skill directory name?

## Commands

- `mkdir -p .claude/skills`
- `ln -sfn ../../claude/skills/{{skill.name}} .claude/skills/{{skill.name}}`
