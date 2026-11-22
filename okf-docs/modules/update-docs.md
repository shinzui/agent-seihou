---
type: SeihouModule
title: update-docs
description: Claude skill to update project documentation after code changes
resource: seihou://agent-seihou/modules/update-docs
tags:
- claude
- skill
- docs
status: stable
generated:
  by: seihou-okf-extension/0.16.0.2
seihouMigrationEdges: []
version: 0.1.0
---

# update-docs

Claude skill to update project documentation after code changes

**Version:** 0.1.0

## When to use

Use this module to generate or manage the files listed under Generation steps.

## How to use

Run from the project directory. Supply the required Variables through Seihou configuration, its prompts or `--var KEY=VALUE`.

If the artifact is not installed, set `REGISTRY_GIT_URL` to the Git URL of its publishing registry and run:

```bash
seihou install "$REGISTRY_GIT_URL" --module update-docs
```

```bash
seihou run update-docs --dry-run
seihou run update-docs
```

Review the planned files and commands in the preview. Applying the plan writes the files, runs the declared commands and records the application in the project manifest.

## Declaration metadata

- description: `Claude skill to update project documentation after code changes. Analyzes commits since last review and ensures docs stay in sync.`

## Dependencies

- [claude-skill-link](/modules/claude-skill-link.md) (declaring registry)

## Variables

- `project.name` — text, required, matching `[a-z][a-z0-9-]*`. The name of the project (e.g. rei, myapp)
- `project.description` — text, required. Short project description for context in the skill
- `skill.name` — text, required, matching `[a-z][a-z0-9-]*`. Skill directory name, derived from project.name (e.g. rei-update-docs)
- `changelog.path` — text, required, default `docs/user/CHANGELOG.md`. Path to the changelog file that tracks the last reviewed commit
- `docs.user.dir` — text, required, default `docs/user`. Directory for user-facing documentation
- `docs.dev.dir` — text, required, default `docs/dev`. Directory for developer documentation
- `source.dirs` — text, required, default `src/`. Comma-separated source directories to analyze for changes
- `cli.commands.dir` — text, optional. Directory containing CLI command modules (e.g. src/Cli/Commands/)
- `skills.dir` — text, optional, default `claude/skills`. Directory containing Claude skill definitions

## Exports

- `skill.name`

## Prompts

- `project.name` — `What is your project name?`
- `project.description` — `Short description of the project?`
- `skill.name` — `Skill directory name (e.g. myproject-update-docs)?`
- `changelog.path` — `Path to changelog file?`
- `docs.user.dir` — `User documentation directory?`
- `docs.dev.dir` — `Developer documentation directory?`
- `source.dirs` — `Source directories to watch (comma-separated)?`
- `cli.commands.dir` — `CLI commands directory (leave empty if no CLI)?`
- `skills.dir` — `Claude skills directory?`

## Generation steps

- `Template` `SKILL.md.tpl` → `claude/skills/{{skill.name}}/SKILL.md` — Managed: owned and reconciled by Seihou updates
