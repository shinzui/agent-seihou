# link-skill

> Symlink a skill from `agents/skills/` into both `.claude/skills/` and `.agents/skills/`.
> Ensures the target directories exist and creates relative symlinks so the skill is
> discoverable by Claude Code and other agent harnesses that read `.agents/skills/`.

**Version:** `0.2.0`

## Overview

Infrastructure module for skill modules that want their `agents/skills/<name>/` content
visible to both Claude Code (which reads `.claude/skills/`) and other agent harnesses
(which read `.agents/skills/`). It does not generate skill files of its own — its real
work is `mkdir` plus two `ln -sfn` commands per target. Pulls in `claude-gitignore` so
`.claude/` is ignored, and adds `.agents/` to `.gitignore` itself.

## Variables

| Name | Type | Default | Required | Validation | Description |
|------|------|---------|----------|------------|-------------|
| `skill.name` | `text` | — | yes | `[a-z][a-z0-9-]*` | Name of the skill directory (e.g. `rei-update-docs`) |

## Prompts

The following values are asked interactively (unless supplied via `--var`):

- **`skill.name`** — What is the skill directory name?

## Dependencies

This module pulls in:

- **`claude-gitignore`**

## Generated Files

When run, this module writes:

- `.gitignore` — strategy: `template`
  - Patch mode: `append-line-if-absent`

## Commands

After file generation, this module runs:

- `mkdir -p .claude/skills`
- `ln -sfn ../../agents/skills/{{skill.name}} .claude/skills/{{skill.name}}`
- `mkdir -p .agents/skills`
- `ln -sfn ../../agents/skills/{{skill.name}} .agents/skills/{{skill.name}}`

## Removal

This module is **not removable** — `seihou remove link-skill` will refuse. Symlinks
created by this module will have to be removed manually.

## Usage

Apply the module:

```bash
seihou run link-skill --var skill.name=my-skill
```

Preview without writing files:

```bash
seihou run link-skill --var skill.name=my-skill --dry-run
```

Typically pulled in transitively by skill modules (e.g. `master-plan`, `exec-plan`)
rather than applied directly.

## See Also

- `module.dhall` — full module definition and authoritative source
- `claude-skill-link` — the single-target predecessor (`.claude/skills/` only)
- `files/` — template sources
