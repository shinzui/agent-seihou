---
type: SeihouModule
title: exec-plan-digest
description: Claude skill that emits a standardized JSON digest of ExecPlans — status,
  progress, discoveries, decisions, commit-trailer coverage, and prioritized findings
  for things a human skimming would miss
resource: seihou://agent-seihou/modules/exec-plan-digest
tags:
- claude
- skill
- planning
status: stable
generated:
  by: seihou-okf-extension/0.8.0.0
version: 0.1.0
---

# exec-plan-digest

Claude skill that emits a standardized JSON digest of ExecPlans — status, progress, discoveries, decisions, commit-trailer coverage, and prioritized findings for things a human skimming would miss

**Version:** 0.1.0

## Dependencies

- [exec-plan](/modules/exec-plan.md) (with `skill.name` = `exec-plan`)
- [claude-skill-link](/modules/claude-skill-link.md) (with `skill.name` = `exec-plan-digest`)

## Variables

- `digest.skill.name` — text, required, default `exec-plan-digest`, matching `[a-z][a-z0-9-]*`. Name of the exec-plan-digest skill directory
- `exec-plan.skill.name` — text, required, default `exec-plan`, matching `[a-z][a-z0-9-]*`. Name of the exec-plan skill this digest summarizes (kept in sync with the exec-plan dependency)

## Exports

- `digest.skill.name`

## Generation steps

- `Copy` `SKILL.md` → `claude/skills/{{digest.skill.name}}/SKILL.md`
- `Copy` `FINDINGS.md` → `claude/skills/{{digest.skill.name}}/FINDINGS.md`
