# exec-plan

> Claude skill for creating, implementing, and managing execution plans (ExecPlans) —
> self-contained design documents that guide implementation of features and system
> changes.

**Version:** `0.1.3`

## Overview

Installs an `exec-plan` skill into the target project's Claude skill directory and
links it into `.claude/skills/` via the `claude-skill-link` dependency. When
`intentions.enabled` is true, appends an intention-tracking section to the skill's
`SKILL.md` so ExecPlans carry `Intention:` trailers in their commits.

## Variables

| Name | Type | Default | Required | Validation | Description |
|------|------|---------|----------|------------|-------------|
| `skill.name` | `text` | `exec-plan` | yes | `[a-z][a-z0-9-]*` | Name of the skill directory |
| `intentions.enabled` | `bool` | `false` | no | — | Enable intention tracking — prompts the user for an Intention ID and adds an `Intention:` trailer to commits |

## Prompts

The following values are asked interactively (unless supplied via `--var`):

- **`intentions.enabled`** — Enable intention tracking for commits?

## Dependencies

This module pulls in:

- **`claude-skill-link`**
  - Variable bindings:
    - `skill.name` = `exec-plan`

## Exports

Variables this module exposes to parent modules:

- `skill.name`

## Generated Files

When run, this module writes:

- `claude/skills/{{skill.name}}/SKILL.md` — strategy: `copy`
- `claude/skills/{{skill.name}}/PLANS.md` — strategy: `copy`
- `claude/skills/{{skill.name}}/SKILL.md` — strategy: `copy`
  - Applied when: `Eq intentions.enabled true`
  - Patch mode: `append-section`

`dest` may contain `{{var}}` placeholders; they are resolved at run time.

## Removal

This module is **not removable** — `seihou remove exec-plan` will refuse. File
additions made by this module will have to be reverted manually.

## Usage

Apply the module:

```bash
seihou run exec-plan
```

With variable overrides:

```bash
seihou run exec-plan --var intentions.enabled=true
```

Preview without writing files:

```bash
seihou run exec-plan --dry-run
```

## See Also

- `module.dhall` — full module definition and authoritative source
- `files/` — template sources
