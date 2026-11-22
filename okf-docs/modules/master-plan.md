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
  by: seihou-okf-extension/0.16.0.2
seihouMigrationEdges:
- anchor: migration-0_2e_1_2e_0-0_2e_2_2e_0
  from: 0.1.0
  to: 0.2.0
version: 0.14.0
---

# master-plan

Claude skill for creating and managing master plans (MasterPlans) — coordination documents that decompose large initiatives into multiple ExecPlans

**Version:** 0.14.0

## When to use

Use this module to generate or manage the files listed under Generation steps.

## How to use

Run from the project directory. Supply the required Variables through Seihou configuration, its prompts or `--var KEY=VALUE`.

If the artifact is not installed, set `REGISTRY_GIT_URL` to the Git URL of its publishing registry and run:

```bash
seihou install "$REGISTRY_GIT_URL" --module master-plan
```

```bash
seihou run master-plan --dry-run
seihou run master-plan
```

Review the planned files and commands in the preview. Applying the plan writes the files, runs the declared commands and records the application in the project manifest.

## Declaration metadata

- description: `Claude skill for creating and managing master plans (MasterPlans) — coordination documents that decompose large initiatives into multiple ExecPlans with dependencies and integration points.`

## Dependencies

- [agent-gitignore](/modules/agent-gitignore.md) (declaring registry)
- [exec-plan](/modules/exec-plan.md) (declaring registry) (with `skill.name` = `exec-plan`)

## Variables

- `mp.skill.name` — text, required, default `master-plan`, matching `[a-z][a-z0-9-]*`. Name of the master-plan skill directory
- `exec-plan.skill.name` — text, required, default `exec-plan`, matching `[a-z][a-z0-9-]*`. Name of the exec-plan skill directory (for cross-references in templates)
- `intentions.enabled` — boolean, optional, default `false`. Enable intention tracking — reuses an existing plan Intention ID or prompts when missing, and adds an Intention: trailer to commits

## Exports

- `mp.skill.name`

## Prompts

- `intentions.enabled` — `Enable intention tracking for commits?`

## Generation steps

- `Template` `SKILL.md` → `agents/skills/{{mp.skill.name}}/SKILL.md` — Managed: owned and reconciled by Seihou updates
- `Template` `MASTERPLAN.md` → `agents/skills/{{mp.skill.name}}/MASTERPLAN.md` — Managed: owned and reconciled by Seihou updates
- `Template` `init-masterplan.ts` → `agents/skills/{{mp.skill.name}}/init-masterplan.ts` — Managed: owned and reconciled by Seihou updates
- `Copy` `INTENTIONS-SECTION.md` → `agents/skills/{{mp.skill.name}}/SKILL.md` (appends a marked section to a file another module owns) — when `Eq intentions.enabled true` — Managed: owned and reconciled by Seihou updates
- `Symlink` `agents/skills/{{mp.skill.name}}` → `.claude/skills/{{mp.skill.name}}` — Checkout: portable symlink restored by `seihou sync` in fresh clones and worktrees
- `Symlink` `agents/skills/{{mp.skill.name}}` → `.codex/skills/{{mp.skill.name}}` — Checkout: portable symlink restored by `seihou sync` in fresh clones and worktrees
- `Symlink` `agents/skills/{{mp.skill.name}}` → `.agents/skills/{{mp.skill.name}}` — Checkout: portable symlink restored by `seihou sync` in fresh clones and worktrees

## Migrations

<a id="migration-0_2e_1_2e_0-0_2e_2_2e_0"></a>

### 0.1.0 → 0.2.0

From a project with `master-plan` applied at `0.1.0`, preview the migration to `0.2.0`. Remove `--dry-run` to apply the operations below and advance the recorded version.

```bash
seihou migrate master-plan --to 0.2.0 --dry-run
```

- move `claude/skills/master-plan/SKILL.md` → `agents/skills/master-plan/SKILL.md`
- move `claude/skills/master-plan/MASTERPLAN.md` → `agents/skills/master-plan/MASTERPLAN.md`
- run `rm -rf .claude/skills/master-plan claude/skills/master-plan`
- run `mkdir -p .claude/skills .agents/skills`
- run `ln -sfn ../../agents/skills/master-plan .claude/skills/master-plan`
- run `ln -sfn ../../agents/skills/master-plan .agents/skills/master-plan`
