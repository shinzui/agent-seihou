# agent-gitignore

> Ensure `.claude/`, `.agents/`, and `CLAUDE.local.md` are in `.gitignore`. Shared
> base module for skill modules that publish into both `.claude/` and `.agents/`.

**Version:** `0.1.0`

## Overview

Appends agent-harness ignore rules to the project's `.gitignore` if they aren't
already present. Use this in place of `claude-gitignore` for projects that surface
skills to multiple agent harnesses (Claude Code via `.claude/`, generic harnesses
via `.agents/`) — for example, projects that pull in `link-skill` or any skill
module built on top of it.

The covered patterns are:

- `.claude/` — Claude Code's per-project skill / settings cache
- `.agents/` — generic agent harness skill cache
- `CLAUDE.local.md` — local Claude memory file

## Generated Files

When run, this module writes:

- `.gitignore` — strategy: `template`
  - Patch mode: `append-line-if-absent`

The patch is idempotent: running the module multiple times does not duplicate lines.

## Removal

This module is **not removable** — `seihou remove agent-gitignore` will refuse. File
additions made by this module will have to be reverted manually.

## Usage

Apply the module:

```bash
seihou run agent-gitignore
```

Preview without writing files:

```bash
seihou run agent-gitignore --dry-run
```

## See Also

- `module.dhall` — full module definition and authoritative source
- `files/` — template sources
- `modules/claude-gitignore` — narrower variant for projects that only use `.claude/`
