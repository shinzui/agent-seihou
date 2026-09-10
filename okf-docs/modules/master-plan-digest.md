---
type: SeihouModule
title: master-plan-digest
description: Claude skill that emits a standardized JSON digest of MasterPlans — registry,
  dependency graph (ready/blocked/critical path), per-child exec-plan digests, trailer
  coverage, and coordination findings (registry drift, cascade gaps, integration-point
  violations)
resource: seihou://agent-seihou/modules/master-plan-digest
tags:
- claude
- skill
- planning
status: stable
generated:
  by: seihou-okf-extension/0.8.0.0
version: 0.1.0
---

# master-plan-digest

Claude skill that emits a standardized JSON digest of MasterPlans — registry, dependency graph (ready/blocked/critical path), per-child exec-plan digests, trailer coverage, and coordination findings (registry drift, cascade gaps, integration-point violations)

**Version:** 0.1.0

## Dependencies

- [master-plan](/modules/master-plan.md) (with `mp.skill.name` = `master-plan`)
- [exec-plan-digest](/modules/exec-plan-digest.md) (with `digest.skill.name` = `exec-plan-digest`)
- [claude-skill-link](/modules/claude-skill-link.md) (with `skill.name` = `master-plan-digest`)

## Variables

- `mp-digest.skill.name` — text, required, default `master-plan-digest`, matching `[a-z][a-z0-9-]*`. Name of the master-plan-digest skill directory
- `master-plan.skill.name` — text, required, default `master-plan`, matching `[a-z][a-z0-9-]*`. Name of the master-plan skill this digest summarizes (kept in sync with the master-plan dependency)
- `exec-plan-digest.skill.name` — text, required, default `exec-plan-digest`, matching `[a-z][a-z0-9-]*`. Name of the exec-plan-digest skill used for per-child digests

## Exports

- `mp-digest.skill.name`

## Generation steps

- `Copy` `SKILL.md` → `claude/skills/{{mp-digest.skill.name}}/SKILL.md`
- `Copy` `FINDINGS.md` → `claude/skills/{{mp-digest.skill.name}}/FINDINGS.md`
