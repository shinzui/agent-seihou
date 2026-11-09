---
type: SeihouModule
title: technical-docs
description: Agent skills for writing tutorials, how-to guides, reference, explanations,
  and code walkthroughs
resource: seihou://agent-seihou/modules/technical-docs
tags:
- claude
- agents
- skill
- docs
status: stable
generated:
  by: seihou-okf-extension/0.15.0.0
version: 0.1.0
---

# technical-docs

Agent skills for writing tutorials, how-to guides, reference, explanations, and code walkthroughs

**Version:** 0.1.0

## Dependencies

- [agent-gitignore](/modules/agent-gitignore.md)

## Variables

- `skill.prefix` — text, optional, default `tech-docs`, matching `[a-z][a-z0-9-]*`. Name of the entry skill and prefix of the five form skills

## Exports

- `skill.prefix`

## Generation steps

- `Template` `router/SKILL.md` → `agents/skills/{{skill.prefix}}/SKILL.md`
- `Copy` `shared/WRITING-RULES.md` → `agents/skills/{{skill.prefix}}/WRITING-RULES.md`
- `Symlink` `agents/skills/{{skill.prefix}}` → `.claude/skills/{{skill.prefix}}`
- `Symlink` `agents/skills/{{skill.prefix}}` → `.codex/skills/{{skill.prefix}}`
- `Symlink` `agents/skills/{{skill.prefix}}` → `.agents/skills/{{skill.prefix}}`
- `Template` `tutorial/SKILL.md` → `agents/skills/{{skill.prefix}}-tutorial/SKILL.md`
- `Copy` `shared/WRITING-RULES.md` → `agents/skills/{{skill.prefix}}-tutorial/WRITING-RULES.md`
- `Symlink` `agents/skills/{{skill.prefix}}-tutorial` → `.claude/skills/{{skill.prefix}}-tutorial`
- `Symlink` `agents/skills/{{skill.prefix}}-tutorial` → `.codex/skills/{{skill.prefix}}-tutorial`
- `Symlink` `agents/skills/{{skill.prefix}}-tutorial` → `.agents/skills/{{skill.prefix}}-tutorial`
- `Template` `how-to/SKILL.md` → `agents/skills/{{skill.prefix}}-how-to/SKILL.md`
- `Copy` `shared/WRITING-RULES.md` → `agents/skills/{{skill.prefix}}-how-to/WRITING-RULES.md`
- `Symlink` `agents/skills/{{skill.prefix}}-how-to` → `.claude/skills/{{skill.prefix}}-how-to`
- `Symlink` `agents/skills/{{skill.prefix}}-how-to` → `.codex/skills/{{skill.prefix}}-how-to`
- `Symlink` `agents/skills/{{skill.prefix}}-how-to` → `.agents/skills/{{skill.prefix}}-how-to`
- `Template` `reference/SKILL.md` → `agents/skills/{{skill.prefix}}-reference/SKILL.md`
- `Copy` `shared/WRITING-RULES.md` → `agents/skills/{{skill.prefix}}-reference/WRITING-RULES.md`
- `Symlink` `agents/skills/{{skill.prefix}}-reference` → `.claude/skills/{{skill.prefix}}-reference`
- `Symlink` `agents/skills/{{skill.prefix}}-reference` → `.codex/skills/{{skill.prefix}}-reference`
- `Symlink` `agents/skills/{{skill.prefix}}-reference` → `.agents/skills/{{skill.prefix}}-reference`
- `Template` `explanation/SKILL.md` → `agents/skills/{{skill.prefix}}-explanation/SKILL.md`
- `Copy` `shared/WRITING-RULES.md` → `agents/skills/{{skill.prefix}}-explanation/WRITING-RULES.md`
- `Symlink` `agents/skills/{{skill.prefix}}-explanation` → `.claude/skills/{{skill.prefix}}-explanation`
- `Symlink` `agents/skills/{{skill.prefix}}-explanation` → `.codex/skills/{{skill.prefix}}-explanation`
- `Symlink` `agents/skills/{{skill.prefix}}-explanation` → `.agents/skills/{{skill.prefix}}-explanation`
- `Template` `walkthrough/SKILL.md` → `agents/skills/{{skill.prefix}}-walkthrough/SKILL.md`
- `Copy` `shared/WRITING-RULES.md` → `agents/skills/{{skill.prefix}}-walkthrough/WRITING-RULES.md`
- `Symlink` `agents/skills/{{skill.prefix}}-walkthrough` → `.claude/skills/{{skill.prefix}}-walkthrough`
- `Symlink` `agents/skills/{{skill.prefix}}-walkthrough` → `.codex/skills/{{skill.prefix}}-walkthrough`
- `Symlink` `agents/skills/{{skill.prefix}}-walkthrough` → `.agents/skills/{{skill.prefix}}-walkthrough`
