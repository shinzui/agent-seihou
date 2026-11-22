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
  by: seihou-okf-extension/0.16.0.2
seihouMigrationEdges: []
version: 0.1.0
---

# technical-docs

Agent skills for writing tutorials, how-to guides, reference, explanations, and code walkthroughs

**Version:** 0.1.0

## When to use

Use this module to generate or manage the files listed under Generation steps.

## How to use

Run from the project directory. Supply the required Variables through Seihou configuration, its prompts or `--var KEY=VALUE`.

If the artifact is not installed, set `REGISTRY_GIT_URL` to the Git URL of its publishing registry and run:

```bash
seihou install "$REGISTRY_GIT_URL" --module technical-docs
```

```bash
seihou run technical-docs --dry-run
seihou run technical-docs
```

Review the planned files and commands in the preview. Applying the plan writes the files, runs the declared commands and records the application in the project manifest.

## Declaration metadata

- description: `Agent skills for writing technical documentation: an entry skill that classifies the reader's need, and skills for tutorials, how-to guides, reference, explanations, and code walkthroughs.`

## Dependencies

- [agent-gitignore](/modules/agent-gitignore.md) (declaring registry)

## Variables

- `skill.prefix` — text, optional, default `tech-docs`, matching `[a-z][a-z0-9-]*`. Name of the entry skill and prefix of the five form skills

## Exports

- `skill.prefix`

## Generation steps

- `Template` `router/SKILL.md` → `agents/skills/{{skill.prefix}}/SKILL.md` — Managed: owned and reconciled by Seihou updates
- `Copy` `shared/WRITING-RULES.md` → `agents/skills/{{skill.prefix}}/WRITING-RULES.md` — Managed: owned and reconciled by Seihou updates
- `Symlink` `agents/skills/{{skill.prefix}}` → `.claude/skills/{{skill.prefix}}` — Checkout: portable symlink restored by `seihou sync` in fresh clones and worktrees
- `Symlink` `agents/skills/{{skill.prefix}}` → `.codex/skills/{{skill.prefix}}` — Checkout: portable symlink restored by `seihou sync` in fresh clones and worktrees
- `Symlink` `agents/skills/{{skill.prefix}}` → `.agents/skills/{{skill.prefix}}` — Checkout: portable symlink restored by `seihou sync` in fresh clones and worktrees
- `Template` `tutorial/SKILL.md` → `agents/skills/{{skill.prefix}}-tutorial/SKILL.md` — Managed: owned and reconciled by Seihou updates
- `Copy` `shared/WRITING-RULES.md` → `agents/skills/{{skill.prefix}}-tutorial/WRITING-RULES.md` — Managed: owned and reconciled by Seihou updates
- `Symlink` `agents/skills/{{skill.prefix}}-tutorial` → `.claude/skills/{{skill.prefix}}-tutorial` — Checkout: portable symlink restored by `seihou sync` in fresh clones and worktrees
- `Symlink` `agents/skills/{{skill.prefix}}-tutorial` → `.codex/skills/{{skill.prefix}}-tutorial` — Checkout: portable symlink restored by `seihou sync` in fresh clones and worktrees
- `Symlink` `agents/skills/{{skill.prefix}}-tutorial` → `.agents/skills/{{skill.prefix}}-tutorial` — Checkout: portable symlink restored by `seihou sync` in fresh clones and worktrees
- `Template` `how-to/SKILL.md` → `agents/skills/{{skill.prefix}}-how-to/SKILL.md` — Managed: owned and reconciled by Seihou updates
- `Copy` `shared/WRITING-RULES.md` → `agents/skills/{{skill.prefix}}-how-to/WRITING-RULES.md` — Managed: owned and reconciled by Seihou updates
- `Symlink` `agents/skills/{{skill.prefix}}-how-to` → `.claude/skills/{{skill.prefix}}-how-to` — Checkout: portable symlink restored by `seihou sync` in fresh clones and worktrees
- `Symlink` `agents/skills/{{skill.prefix}}-how-to` → `.codex/skills/{{skill.prefix}}-how-to` — Checkout: portable symlink restored by `seihou sync` in fresh clones and worktrees
- `Symlink` `agents/skills/{{skill.prefix}}-how-to` → `.agents/skills/{{skill.prefix}}-how-to` — Checkout: portable symlink restored by `seihou sync` in fresh clones and worktrees
- `Template` `reference/SKILL.md` → `agents/skills/{{skill.prefix}}-reference/SKILL.md` — Managed: owned and reconciled by Seihou updates
- `Copy` `shared/WRITING-RULES.md` → `agents/skills/{{skill.prefix}}-reference/WRITING-RULES.md` — Managed: owned and reconciled by Seihou updates
- `Symlink` `agents/skills/{{skill.prefix}}-reference` → `.claude/skills/{{skill.prefix}}-reference` — Checkout: portable symlink restored by `seihou sync` in fresh clones and worktrees
- `Symlink` `agents/skills/{{skill.prefix}}-reference` → `.codex/skills/{{skill.prefix}}-reference` — Checkout: portable symlink restored by `seihou sync` in fresh clones and worktrees
- `Symlink` `agents/skills/{{skill.prefix}}-reference` → `.agents/skills/{{skill.prefix}}-reference` — Checkout: portable symlink restored by `seihou sync` in fresh clones and worktrees
- `Template` `explanation/SKILL.md` → `agents/skills/{{skill.prefix}}-explanation/SKILL.md` — Managed: owned and reconciled by Seihou updates
- `Copy` `shared/WRITING-RULES.md` → `agents/skills/{{skill.prefix}}-explanation/WRITING-RULES.md` — Managed: owned and reconciled by Seihou updates
- `Symlink` `agents/skills/{{skill.prefix}}-explanation` → `.claude/skills/{{skill.prefix}}-explanation` — Checkout: portable symlink restored by `seihou sync` in fresh clones and worktrees
- `Symlink` `agents/skills/{{skill.prefix}}-explanation` → `.codex/skills/{{skill.prefix}}-explanation` — Checkout: portable symlink restored by `seihou sync` in fresh clones and worktrees
- `Symlink` `agents/skills/{{skill.prefix}}-explanation` → `.agents/skills/{{skill.prefix}}-explanation` — Checkout: portable symlink restored by `seihou sync` in fresh clones and worktrees
- `Template` `walkthrough/SKILL.md` → `agents/skills/{{skill.prefix}}-walkthrough/SKILL.md` — Managed: owned and reconciled by Seihou updates
- `Copy` `shared/WRITING-RULES.md` → `agents/skills/{{skill.prefix}}-walkthrough/WRITING-RULES.md` — Managed: owned and reconciled by Seihou updates
- `Symlink` `agents/skills/{{skill.prefix}}-walkthrough` → `.claude/skills/{{skill.prefix}}-walkthrough` — Checkout: portable symlink restored by `seihou sync` in fresh clones and worktrees
- `Symlink` `agents/skills/{{skill.prefix}}-walkthrough` → `.codex/skills/{{skill.prefix}}-walkthrough` — Checkout: portable symlink restored by `seihou sync` in fresh clones and worktrees
- `Symlink` `agents/skills/{{skill.prefix}}-walkthrough` → `.agents/skills/{{skill.prefix}}-walkthrough` — Checkout: portable symlink restored by `seihou sync` in fresh clones and worktrees
