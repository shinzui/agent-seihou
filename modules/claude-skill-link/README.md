# claude-skill-link

> Symlink a Claude skill from `claude/skills/` into `.claude/skills/`. Ensures
> `.claude/skills/` exists and creates a relative symlink so the skill is discoverable
> by Claude Code.

**Version:** `0.1.0`

## Overview

Infrastructure module used by every skill module in this registry. It does not generate
files — it runs `mkdir` and `ln -sfn` to wire a tracked `claude/skills/<name>/`
directory into the Claude Code discovery path at `.claude/skills/<name>`. Pulling in
`claude-gitignore` ensures `.claude/` stays out of version control.

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

## Commands

After file generation, this module runs:

- `mkdir -p .claude/skills`
- `ln -sfn ../../claude/skills/{{skill.name}} .claude/skills/{{skill.name}}`

## Removal

This module is **not removable** — `seihou remove claude-skill-link` will refuse.
Symlinks created by this module will have to be removed manually.

## Usage

Apply the module:

```bash
seihou run claude-skill-link --var skill.name=my-skill
```

Preview without writing files:

```bash
seihou run claude-skill-link --var skill.name=my-skill --dry-run
```

## See Also

- `module.dhall` — full module definition and authoritative source
- `files/` — template sources
