# exec-plan-digest

> Claude skill that produces a standardized JSON digest of ExecPlans — extracts status,
> progress, discoveries, decisions, and outcomes; cross-references git commit trailers;
> and surfaces issues a human skimming the plan would miss (stale active plans,
> orphaned discoveries, missing sections, contradictions).

**Version:** `0.1.0`

## Overview

Installs an `exec-plan-digest` skill alongside the `exec-plan` skill (pulled in as a
dependency) and links it into `.claude/skills/` so Claude Code can invoke it to
produce machine-readable summaries of ExecPlans managed by this project.

## Variables

| Name | Type | Default | Required | Validation | Description |
|------|------|---------|----------|------------|-------------|
| `digest.skill.name` | `text` | `exec-plan-digest` | yes | `[a-z][a-z0-9-]*` | Name of the exec-plan-digest skill directory |
| `exec-plan.skill.name` | `text` | `exec-plan` | yes | `[a-z][a-z0-9-]*` | Name of the exec-plan skill this digest summarizes (kept in sync with the exec-plan dependency) |

## Dependencies

This module pulls in:

- **`exec-plan`**
  - Variable bindings:
    - `skill.name` = `exec-plan`
- **`claude-skill-link`**
  - Variable bindings:
    - `skill.name` = `exec-plan-digest`

## Exports

Variables this module exposes to parent modules:

- `digest.skill.name`

## Generated Files

When run, this module writes:

- `claude/skills/{{digest.skill.name}}/SKILL.md` — strategy: `copy`
- `claude/skills/{{digest.skill.name}}/FINDINGS.md` — strategy: `copy`

`dest` may contain `{{var}}` placeholders; they are resolved at run time.

## Removal

This module is **not removable** — `seihou remove exec-plan-digest` will refuse. File
additions made by this module will have to be reverted manually.

## Usage

Apply the module:

```bash
seihou run exec-plan-digest
```

With variable overrides:

```bash
seihou run exec-plan-digest --var digest.skill.name=ep-digest
```

Preview without writing files:

```bash
seihou run exec-plan-digest --dry-run
```

## See Also

- `module.dhall` — full module definition and authoritative source
- `files/` — template sources
