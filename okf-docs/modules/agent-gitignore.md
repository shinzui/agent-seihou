---
type: SeihouModule
title: agent-gitignore
description: Ensure .claude/, .codex/, .agents/, and CLAUDE.local.md are in .gitignore
resource: seihou://agent-seihou/modules/agent-gitignore
tags:
- claude
- agents
- gitignore
- infrastructure
status: stable
generated:
  by: seihou-okf-extension/0.16.0.2
seihouMigrationEdges: []
version: 0.2.0
---

# agent-gitignore

Ensure .claude/, .codex/, .agents/, and CLAUDE.local.md are in .gitignore

**Version:** 0.2.0

## When to use

Use this module to generate or manage the files listed under Generation steps.

## How to use

Run from the project directory. Supply the required Variables through Seihou configuration, its prompts or `--var KEY=VALUE`.

If the artifact is not installed, set `REGISTRY_GIT_URL` to the Git URL of its publishing registry and run:

```bash
seihou install "$REGISTRY_GIT_URL" --module agent-gitignore
```

```bash
seihou run agent-gitignore --dry-run
seihou run agent-gitignore
```

Review the planned files and commands in the preview. Applying the plan writes the files, runs the declared commands and records the application in the project manifest.

## Declaration metadata

- description: `Ensure .claude/, .codex/, .agents/, and CLAUDE.local.md are in .gitignore. Shared base module for skill modules that publish into all three discovery directories.`

## Dependencies

This module has no dependencies.

## Variables

No variables declared.

## Exports

No exports declared.

## Generation steps

- `Template` `gitignore.tpl` → `.gitignore` (appends one line to a file another module owns, if absent) — Managed: owned and reconciled by Seihou updates
