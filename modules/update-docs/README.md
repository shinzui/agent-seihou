# update-docs

> Claude skill to update project documentation after code changes. Analyzes commits
> since last review and ensures docs stay in sync.

**Version:** `0.1.0`

## Overview

Generates a project-specific `update-docs` skill that walks git history since the last
reviewed commit (tracked in a changelog file) and identifies documentation gaps across
user-facing and developer-facing doc directories. Pulls in `claude-skill-link` to wire
the skill into `.claude/skills/`.

## Variables

| Name | Type | Default | Required | Validation | Description |
|------|------|---------|----------|------------|-------------|
| `project.name` | `text` | — | yes | `[a-z][a-z0-9-]*` | The name of the project (e.g. `rei`, `myapp`) |
| `project.description` | `text` | — | yes | — | Short project description for context in the skill |
| `skill.name` | `text` | — | yes | `[a-z][a-z0-9-]*` | Skill directory name, derived from `project.name` (e.g. `rei-update-docs`) |
| `changelog.path` | `text` | `docs/user/CHANGELOG.md` | yes | — | Path to the changelog file that tracks the last reviewed commit |
| `docs.user.dir` | `text` | `docs/user` | yes | — | Directory for user-facing documentation |
| `docs.dev.dir` | `text` | `docs/dev` | yes | — | Directory for developer documentation |
| `source.dirs` | `text` | `src/` | yes | — | Comma-separated source directories to analyze for changes |
| `cli.commands.dir` | `text` | — | no | — | Directory containing CLI command modules (e.g. `src/Cli/Commands/`) |
| `skills.dir` | `text` | `claude/skills` | no | — | Directory containing Claude skill definitions |

## Prompts

The following values are asked interactively (unless supplied via `--var`):

- **`project.name`** — What is your project name?
- **`project.description`** — Short description of the project?
- **`skill.name`** — Skill directory name (e.g. `myproject-update-docs`)?
- **`changelog.path`** — Path to changelog file?
- **`docs.user.dir`** — User documentation directory?
- **`docs.dev.dir`** — Developer documentation directory?
- **`source.dirs`** — Source directories to watch (comma-separated)?
- **`cli.commands.dir`** — CLI commands directory (leave empty if no CLI)?
- **`skills.dir`** — Claude skills directory?

## Dependencies

This module pulls in:

- **`claude-skill-link`**

## Exports

Variables this module exposes to parent modules:

- `skill.name`

## Generated Files

When run, this module writes:

- `claude/skills/{{skill.name}}/SKILL.md` — strategy: `template`

`dest` may contain `{{var}}` placeholders; they are resolved at run time.

## Removal

This module is **not removable** — `seihou remove update-docs` will refuse. File
additions made by this module will have to be reverted manually.

## Usage

Apply the module:

```bash
seihou run update-docs
```

With variable overrides:

```bash
seihou run update-docs \
  --var project.name=myapp \
  --var "project.description=My awesome project" \
  --var skill.name=myapp-update-docs
```

Preview without writing files:

```bash
seihou run update-docs --dry-run
```

## See Also

- `module.dhall` — full module definition and authoritative source
- `files/` — template sources
