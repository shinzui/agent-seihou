---
type: SeihouModule
title: link-skill
description: Declare manifest-owned checkout links from agents/skills/ into .claude/skills/,
  .codex/skills/ and .agents/skills/
resource: seihou://agent-seihou/modules/link-skill
tags:
- claude
- agents
- skill
- infrastructure
status: stable
generated:
  by: seihou-okf-extension/0.16.0.2
seihouMigrationEdges: []
version: 0.4.0
---

# link-skill

Declare manifest-owned checkout links from agents/skills/ into .claude/skills/, .codex/skills/ and .agents/skills/

**Version:** 0.4.0

## When to use

Use this module to generate or manage the files listed under Generation steps.

## How to use

Run from the project directory. Supply the required Variables through Seihou configuration, its prompts or `--var KEY=VALUE`.

If the artifact is not installed, set `REGISTRY_GIT_URL` to the Git URL of its publishing registry and run:

```bash
seihou install "$REGISTRY_GIT_URL" --module link-skill
```

```bash
seihou run link-skill --dry-run
seihou run link-skill
```

Review the planned files and commands in the preview. Applying the plan writes the files, runs the declared commands and records the application in the project manifest.

## Declaration metadata

- description: `Symlink a skill from agents/skills/ into .claude/skills/, .codex/skills/ and .agents/skills/. Records manifest-owned checkout links, restored by seihou sync in every clone (Seihou 0.11.0.0 or newer).`

## Dependencies

- [claude-gitignore](/modules/claude-gitignore.md) (declaring registry)

## Variables

- `skill.name` — text, required, matching `[a-z][a-z0-9-]*`. Name of the skill directory (e.g. rei-update-docs)

## Exports

No exports declared.

## Prompts

- `skill.name` — `What is the skill directory name?`

## Generation steps

- `Template` `gitignore.tpl` → `.gitignore` (appends one line to a file another module owns, if absent) — Managed: owned and reconciled by Seihou updates
- `Symlink` `agents/skills/{{skill.name}}` → `.claude/skills/{{skill.name}}` — Checkout: portable symlink restored by `seihou sync` in fresh clones and worktrees
- `Symlink` `agents/skills/{{skill.name}}` → `.agents/skills/{{skill.name}}` — Checkout: portable symlink restored by `seihou sync` in fresh clones and worktrees
- `Symlink` `agents/skills/{{skill.name}}` → `.codex/skills/{{skill.name}}` — Checkout: portable symlink restored by `seihou sync` in fresh clones and worktrees
