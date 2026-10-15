# link-skill

> Symlink a skill from `agents/skills/` into both `.claude/skills/` and `.agents/skills/`.
> Ensures the target directories exist and creates relative symlinks so the skill is
> discoverable by Claude Code and other agent harnesses that read `.agents/skills/`.

**Version:** `0.3.0`

## Overview

Infrastructure module for skill modules that want their `agents/skills/<name>/` content
visible to both Claude Code (which reads `.claude/skills/`) and other agent harnesses
(which read `.agents/skills/`). It records two manifest-owned checkout declarations and does not generate skill files.
Requires Seihou **0.10.0.0** or newer (the minimum tested released runtime). Pulls in `claude-gitignore` so
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

## Checkout declarations

Both steps use `strategy = "symlink"` and `lifecycle = Some "checkout"`:

| Source | Discovery destination |
|--------|-----------------------|
| `agents/skills/{{skill.name}}` | `.claude/skills/{{skill.name}}` |
| `agents/skills/{{skill.name}}` | `.agents/skills/{{skill.name}}` |

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

Typically pulled in transitively by skill modules (e.g. `master-plan`, `exec-plan`)
rather than applied directly.

## Existing projects and clones

Install the new producer and update the application's root target once; for an
existing master-plan composition:

```bash
seihou install https://github.com/shinzui/agent-seihou.git --module master-plan --module exec-plan --module link-skill --module agent-gitignore --module claude-gitignore
seihou update master-plan --dry-run --json --no-commands
seihou update master-plan --json --no-commands
```

The parent module versions can stay unchanged: update discovers the new link-skill
dependency. Commit `.seihou/manifest.json`, `.gitignore`, and the source skill tree.
Installation or `seihou manifest upgrade` alone cannot infer declarations from old
command receipts. Historical source-move migrations remain separate from current
link declarations; `seihou update` includes applicable migrations.

After cloning that committed state, use only:

```bash
seihou sync --dry-run --json
seihou sync --json
```

Sync needs no producer installation, performs no upgrades, and leaves tracked files
and manifest bytes unchanged. It restores deleted links and repairs wrong symlinks.
The source content must be committed too; an empty directory is not retained by Git.

## See Also

- `module.dhall` — full module definition and authoritative source
- `claude-skill-link` — the single-target predecessor (`.claude/skills/` only)
- `files/` — template sources
