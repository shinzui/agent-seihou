# link-skill

> Symlink a skill from `agents/skills/` into `.claude/skills/`, `.codex/skills/` and `.agents/skills/`.
> Ensures the target directories exist and creates relative symlinks so the skill is
> discoverable by Claude Code and other agent harnesses that read `.agents/skills/`.

**Version:** `0.4.0`

## Overview

Infrastructure module for skill modules that want their `agents/skills/<name>/` content
visible to both Claude Code (which reads `.claude/skills/`) and other agent harnesses
(which read `.agents/skills/`). It records three manifest-owned checkout declarations and does not generate skill files.
The complete adoption workflow requires Seihou **0.11.0.0** or newer (runtime release pending). Pulls in `claude-gitignore` so
`.claude/` is ignored, and adds `.codex/` and `.agents/` to `.gitignore` itself.

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

## Checkout declarations

All three link steps use `strategy = "symlink"` and `lifecycle = Some "checkout"`:

| Source | Discovery destination |
|--------|-----------------------|
| `agents/skills/{{skill.name}}` | `.claude/skills/{{skill.name}}` |
| `agents/skills/{{skill.name}}` | `.agents/skills/{{skill.name}}` |
| `agents/skills/{{skill.name}}` | `.codex/skills/{{skill.name}}` |

The source must be a real project directory, either already present or generated in
this composition. Destinations must be ignored and untracked for `seihou sync`.
Seihou creates parents and relative link targets. A real file or directory at a
destination causes safe refusal; it is never overwritten. No setup shell commands
run, including with `--no-commands`.

## Removal

`seihou remove link-skill --application <id>` retires the selected application's
checkout claims. Agreeing owners retain their claims. After the last owner retires,
Seihou removes only an unchanged declared link; locally changed objects survive with
a warning. This automatic cleanup does not remove unrelated shared `.gitignore`
patches or tracked skill source content and does not promise full module reversal.

## Usage

Apply the module:

```bash
mkdir -p agents/skills/my-skill
# Put the real skill files in this directory before applying.
seihou run link-skill --var skill.name=my-skill --no-commands
```

Preview without writing files:

```bash
seihou run link-skill --var skill.name=my-skill --dry-run
```

Use this standalone module for existing skill sources. Planning modules now own
their links directly so custom source names and discovery names stay aligned.

## Existing projects and clones

A maintainer updates the recorded application's root once, for example:

```sh
seihou update master-plan
```

Review and accept its preview, then commit manifest, baselines, ignore rules and
source assets. Update owns fetching and saved inputs. Teammates receive that commit
and run plain `seihou sync`; no producers, flags, configuration prompts or project
state changes are required for restoration. The source content must be committed:
Git does not retain empty directories.

## See Also

- `module.dhall` — full module definition and authoritative source
- `claude-skill-link` — the single-target predecessor (`.claude/skills/` only)
- `files/` — template sources
