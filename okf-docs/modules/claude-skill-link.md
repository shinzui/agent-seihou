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
  by: seihou-okf-extension/0.16.0.2
seihouMigrationEdges: []
version: 0.2.0
---

# claude-skill-link

Declare a manifest-owned checkout link from claude/skills/ into .claude/skills/

**Version:** 0.2.0

## When to use

Use this module to generate or manage the files listed under Generation steps.

## How to use

Run from the project directory. Supply the required Variables through Seihou configuration, its prompts or `--var KEY=VALUE`.

If the artifact is not installed, set `REGISTRY_GIT_URL` to the Git URL of its publishing registry and run:

```bash
seihou install "$REGISTRY_GIT_URL" --module claude-skill-link
```

```bash
seihou run claude-skill-link --dry-run
seihou run claude-skill-link
```

Review the planned files and commands in the preview. Applying the plan writes the files, runs the declared commands and records the application in the project manifest.

## Declaration metadata

- description: `Symlink a Claude skill from claude/skills/ into .claude/skills/. Records a manifest-owned checkout link restored by seihou sync in every clone (Seihou 0.10.0.0 or newer).`

## Dependencies

- [claude-gitignore](/modules/claude-gitignore.md) (declaring registry)

## Variables

- `skill.name` — text, required, matching `[a-z][a-z0-9-]*`. Name of the skill directory (e.g. rei-update-docs)

## Exports

No exports declared.

## Prompts

- `skill.name` — `What is the skill directory name?`

## Generation steps

- `Symlink` `claude/skills/{{skill.name}}` → `.claude/skills/{{skill.name}}` — Checkout: portable symlink restored by `seihou sync` in fresh clones and worktrees
