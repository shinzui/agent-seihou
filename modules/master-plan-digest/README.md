# master-plan-digest

> Claude skill that emits a standardized JSON digest of MasterPlans — parses the
> Exec-Plan Registry, computes the dependency graph (ready/blocked/critical path/parallel
> frontier), embeds per-child exec-plan-digest output, cross-references git commit
> trailers (`MasterPlan:` and `ExecPlan:`), and surfaces coordination issues a human
> would miss (registry drift, cascade gaps, integration-point violations, missing
> back-references).

**Version:** `0.1.0`

## Overview

Installs a `master-plan-digest` skill alongside the `master-plan` and `exec-plan-digest`
skills (pulled in as dependencies) and links it into `.claude/skills/` so Claude Code
can invoke it to produce machine-readable summaries of the MasterPlans managed by this
project.

## Variables

| Name | Type | Default | Required | Validation | Description |
|------|------|---------|----------|------------|-------------|
| `mp-digest.skill.name` | `text` | `master-plan-digest` | yes | `[a-z][a-z0-9-]*` | Name of the master-plan-digest skill directory |
| `master-plan.skill.name` | `text` | `master-plan` | yes | `[a-z][a-z0-9-]*` | Name of the master-plan skill this digest summarizes (kept in sync with the master-plan dependency) |
| `exec-plan-digest.skill.name` | `text` | `exec-plan-digest` | yes | `[a-z][a-z0-9-]*` | Name of the exec-plan-digest skill used for per-child digests |

## Dependencies

This module pulls in:

- **`master-plan`**
  - Variable bindings:
    - `mp.skill.name` = `master-plan`
- **`exec-plan-digest`**
  - Variable bindings:
    - `digest.skill.name` = `exec-plan-digest`
- **`claude-skill-link`**
  - Variable bindings:
    - `skill.name` = `master-plan-digest`

## Exports

Variables this module exposes to parent modules:

- `mp-digest.skill.name`

## Generated Files

When run, this module writes:

- `claude/skills/{{mp-digest.skill.name}}/SKILL.md` — strategy: `copy`
- `claude/skills/{{mp-digest.skill.name}}/FINDINGS.md` — strategy: `copy`

`dest` may contain `{{var}}` placeholders; they are resolved at run time.

## Removal

This module is **not removable** — `seihou remove master-plan-digest` will refuse. File
additions made by this module will have to be reverted manually.

## Usage

Apply the module:

```bash
seihou run master-plan-digest
```

With variable overrides:

```bash
seihou run master-plan-digest --var mp-digest.skill.name=mp-digest
```

Preview without writing files:

```bash
seihou run master-plan-digest --dry-run
```

## See Also

- `module.dhall` — full module definition and authoritative source
- `files/` — template sources
