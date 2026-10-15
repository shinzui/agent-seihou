# claude-skill-link

> Symlink a Claude skill from `claude/skills/` into `.claude/skills/`. Ensures
> `.claude/skills/` exists and creates a relative symlink so the skill is discoverable
> by Claude Code.

**Version:** `0.2.0`

## Overview

Infrastructure module used by update-docs and other skills that keep their source in
`claude/skills/<name>/`. It records one manifest-owned checkout link to
`.claude/skills/<name>` without generating source files or running setup commands.
Requires Seihou **0.10.0.0** or newer (the minimum tested released runtime). Pulling in
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

## Checkout declaration

The step uses `strategy = "symlink"`, `lifecycle = Some "checkout"`, source
`claude/skills/{{skill.name}}`, and destination `.claude/skills/{{skill.name}}`.
The source must be a real project directory, either already present or generated
in the composition. The destination must be ignored and untracked for sync.
Seihou creates parents and the literal relative target `../../claude/skills/<name>`.
A real file or directory collision is preserved and reported as a refusal.
Declaration application works with `--no-commands`.

## Removal

`seihou remove claude-skill-link --application <id>` retires the selected
application's checkout claims. Other agreeing owners keep the link. Last-owner
cleanup removes only a link that still matches its declaration; edited objects
survive with a warning. Source skill files and unrelated shared ignore patches
are not removed automatically.

## Usage

Apply the module:

```bash
mkdir -p claude/skills/my-skill
# Add the real skill content before applying.
seihou run claude-skill-link --var skill.name=my-skill --no-commands
```

Preview without writing files:

```bash
seihou run claude-skill-link --var skill.name=my-skill --dry-run
```

## Existing applications and clones

For an existing update-docs application:

```bash
seihou install https://github.com/shinzui/agent-seihou.git --module update-docs --module claude-skill-link --module claude-gitignore
seihou update update-docs --dry-run --json --no-commands
seihou update update-docs --json --no-commands
```

Update discovers the changed dependency even when update-docs remains at 0.1.0.
For a directly applied claude-skill-link, update that target instead. Installation
or manifest upgrade alone cannot translate old shell receipts into declarations.
Commit the manifest, ignore rules and `claude/skills/` source files after the
successful update. No source relocation is required.

Fresh clones and linked worktrees then run:

```bash
seihou sync --dry-run --json
seihou sync --json
```

No producer installation is needed. Sync leaves tracked content and manifest bytes
unchanged, restores deleted links, and repairs incorrectly targeted symlinks.

## See Also

- `module.dhall` — full module definition and authoritative source
- `files/` — template sources
