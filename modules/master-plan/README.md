# master-plan

> Claude skill for creating and managing master plans (MasterPlans) — coordination
> documents that decompose large initiatives into multiple ExecPlans with dependencies
> and integration points.

**Version:** `0.1.0`

## Overview

Installs a `master-plan` skill into the target project's Claude skill directory, pairing
it with an `exec-plan` skill (pulled in as a dependency) and linking both into
`.claude/skills/` so Claude Code can discover them.

## Variables

| Name | Type | Default | Required | Validation | Description |
|------|------|---------|----------|------------|-------------|
| `mp.skill.name` | `text` | `master-plan` | yes | `[a-z][a-z0-9-]*` | Name of the master-plan skill directory |
| `exec-plan.skill.name` | `text` | `exec-plan` | yes | `[a-z][a-z0-9-]*` | Name of the exec-plan skill directory (for cross-references in templates) |
| `intentions.enabled` | `bool` | `false` | no | — | Enable intention tracking — prompts the user for an Intention ID and adds an `Intention:` trailer to commits |

## Prompts

The following values are asked interactively (unless supplied via `--var`):

- **`intentions.enabled`** — Enable intention tracking for commits?

## Dependencies

This module pulls in:

- **`exec-plan`**
  - Variable bindings:
    - `skill.name` = `exec-plan`
- **`claude-skill-link`**
  - Variable bindings:
    - `skill.name` = `master-plan`

## Exports

Variables this module exposes to parent modules:

- `mp.skill.name`

## Generated Files

When run, this module writes:

- `claude/skills/{{mp.skill.name}}/SKILL.md` — strategy: `template`
- `claude/skills/{{mp.skill.name}}/MASTERPLAN.md` — strategy: `template`
- `claude/skills/{{mp.skill.name}}/SKILL.md` — strategy: `copy`
  - Applied when: `Eq intentions.enabled true`
  - Patch mode: `append-section`

`dest` may contain `{{var}}` placeholders; they are resolved at run time.

## Removal

This module is **not removable** — `seihou remove master-plan` will refuse. File
additions made by this module will have to be reverted manually.

## Usage

Apply the module:

```bash
seihou run master-plan
```

With variable overrides:

```bash
seihou run master-plan --var mp.skill.name=my-master-plan
```

Preview without writing files:

```bash
seihou run master-plan --dry-run
```

## See Also

- `module.dhall` — full module definition and authoritative source
- `files/` — template sources
