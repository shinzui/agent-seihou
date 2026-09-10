---
type: SeihouModule
title: exec-plan
description: Claude skill for creating and managing execution plans (ExecPlans)
resource: seihou://agent-seihou/modules/exec-plan
tags:
- claude
- skill
- planning
status: stable
generated:
  by: seihou-okf-extension/0.8.0.0
version: 0.10.0
---

# exec-plan

Claude skill for creating and managing execution plans (ExecPlans)

**Version:** 0.10.0

## Dependencies

- [agent-gitignore](/modules/agent-gitignore.md)
- [link-skill](/modules/link-skill.md) (with `skill.name` = `exec-plan`)

## Variables

- `skill.name` — text, required, default `exec-plan`, matching `[a-z][a-z0-9-]*`. Name of the skill directory
- `intentions.enabled` — boolean, optional, default `false`. Enable intention tracking — reuses an existing plan Intention ID or prompts when missing, and adds an Intention: trailer to commits

## Exports

- `skill.name`

## Prompts

- `intentions.enabled` — Enable intention tracking for commits?

## Generation steps

- `Template` `SKILL.md` → `agents/skills/{{skill.name}}/SKILL.md`
- `Copy` `PLANS.md` → `agents/skills/{{skill.name}}/PLANS.md`
- `Copy` `ADR.md` → `agents/skills/{{skill.name}}/ADR.md`
- `Copy` `init-plan.ts` → `agents/skills/{{skill.name}}/init-plan.ts`
- `Copy` `record-provenance.ts` → `agents/skills/{{skill.name}}/record-provenance.ts`
- `Copy` `provenance-model.ts` → `agents/skills/{{skill.name}}/provenance-model.ts`
- `Copy` `PROVENANCE.md` → `agents/skills/{{skill.name}}/PROVENANCE.md`
- `Copy` `INTENTIONS-SECTION.md` → `agents/skills/{{skill.name}}/SKILL.md` (appends a marked section to a file another module owns) — when `Eq intentions.enabled true`

## Migrations

### 0.1.3 → 0.2.0

- move `claude/skills/exec-plan/SKILL.md` → `agents/skills/exec-plan/SKILL.md`
- move `claude/skills/exec-plan/PLANS.md` → `agents/skills/exec-plan/PLANS.md`
- run `rm -rf .claude/skills/exec-plan claude/skills/exec-plan`
- run `mkdir -p .claude/skills .agents/skills`
- run `ln -sfn ../../agents/skills/exec-plan .claude/skills/exec-plan`
- run `ln -sfn ../../agents/skills/exec-plan .agents/skills/exec-plan`


### 0.7.0 → 0.8.0

- run `if [ -d docs/adr ] && [ -n "$(find docs/adr -type f -name '*.md' ! -name index.md ! -name log.md -print -quit)" ]; then seihou install https://github.com/shinzui/okf-profiles.git --module adopt-architecture-decisions && seihou agent run adopt-architecture-decisions "Reconcile existing ADRs during the exec-plan 0.8.0 upgrade. Preserve repository-specific history and conventions while enforcing the shared profile. Do not stop until strict profile and log validation passes." --batch --provider claude-cli --model claude-sonnet-5 && test -f docs/adr/profile.dhall && dhall type --file docs/adr/profile.dhall >/dev/null && okf validate docs/adr --strict --profile docs/adr/profile.dhall --profile-enforce --log-enforce; fi`
