---
type: SeihouModule
title: master-plan
description: Claude skill for creating and managing master plans (MasterPlans) — coordination
  documents that decompose large initiatives into multiple ExecPlans
resource: seihou://agent-seihou/modules/master-plan
tags:
- claude
- skill
- planning
status: stable
generated:
  by: seihou-okf-extension/0.8.0.0
version: 0.10.0
---

# master-plan

Claude skill for creating and managing master plans (MasterPlans) — coordination documents that decompose large initiatives into multiple ExecPlans

**Version:** 0.10.0

## Dependencies

- [agent-gitignore](/modules/agent-gitignore.md)
- [exec-plan](/modules/exec-plan.md) (with `skill.name` = `exec-plan`)
- [link-skill](/modules/link-skill.md) (with `skill.name` = `master-plan`)

## Variables

- `mp.skill.name` — text, required, default `master-plan`, matching `[a-z][a-z0-9-]*`. Name of the master-plan skill directory
- `exec-plan.skill.name` — text, required, default `exec-plan`, matching `[a-z][a-z0-9-]*`. Name of the exec-plan skill directory (for cross-references in templates)
- `intentions.enabled` — boolean, optional, default `false`. Enable intention tracking — reuses an existing plan Intention ID or prompts when missing, and adds an Intention: trailer to commits

## Exports

- `mp.skill.name`

## Prompts

- `intentions.enabled` — Enable intention tracking for commits?

## Generation steps

- `Template` `SKILL.md` → `agents/skills/{{mp.skill.name}}/SKILL.md`
- `Template` `MASTERPLAN.md` → `agents/skills/{{mp.skill.name}}/MASTERPLAN.md`
- `Template` `init-masterplan.ts` → `agents/skills/{{mp.skill.name}}/init-masterplan.ts`
- `Copy` `INTENTIONS-SECTION.md` → `agents/skills/{{mp.skill.name}}/SKILL.md` (appends a marked section to a file another module owns) — when `Eq intentions.enabled true`

## Migrations

### 0.1.0 → 0.2.0

- move `claude/skills/master-plan/SKILL.md` → `agents/skills/master-plan/SKILL.md`
- move `claude/skills/master-plan/MASTERPLAN.md` → `agents/skills/master-plan/MASTERPLAN.md`
- run `rm -rf .claude/skills/master-plan claude/skills/master-plan`
- run `mkdir -p .claude/skills .agents/skills`
- run `ln -sfn ../../agents/skills/master-plan .claude/skills/master-plan`
- run `ln -sfn ../../agents/skills/master-plan .agents/skills/master-plan`
