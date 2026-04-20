# claude-gitignore

> Ensure `.claude/` and `CLAUDE.local.md` are in `.gitignore`. Shared base module for
> Claude-related modules.

**Version:** `0.2.0`

## Overview

Appends the Claude-specific ignore rules to the project's `.gitignore` if they aren't
already present. Pulled in as a dependency by other Claude-related modules
(`claude-skill-link`, and transitively, every skill module) so that generated
`.claude/` artifacts are never committed.

## Generated Files

When run, this module writes:

- `.gitignore` — strategy: `template`
  - Patch mode: `append-line-if-absent`

The patch is idempotent: running the module multiple times does not duplicate lines.

## Removal

This module is **not removable** — `seihou remove claude-gitignore` will refuse. File
additions made by this module will have to be reverted manually.

## Usage

Apply the module:

```bash
seihou run claude-gitignore
```

Preview without writing files:

```bash
seihou run claude-gitignore --dry-run
```

## See Also

- `module.dhall` — full module definition and authoritative source
- `files/` — template sources
