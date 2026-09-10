---
type: SeihouModule
title: link-skill
description: Symlink a skill from claude/skills/ into both .claude/skills/ and .agents/skills/
resource: seihou://agent-seihou/modules/link-skill
tags:
- claude
- agents
- skill
- infrastructure
status: stable
generated:
  by: seihou-okf-extension/0.8.0.0
version: 0.2.0
---

# link-skill

Symlink a skill from claude/skills/ into both .claude/skills/ and .agents/skills/

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

- `Template` `gitignore.tpl` → `.gitignore` (appends one line to a file another module owns, if absent)

## Commands

- `mkdir -p .claude/skills`
- `ln -sfn ../../agents/skills/{{skill.name}} .claude/skills/{{skill.name}}`
- `mkdir -p .agents/skills`
- `ln -sfn ../../agents/skills/{{skill.name}} .agents/skills/{{skill.name}}`
