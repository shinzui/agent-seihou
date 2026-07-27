# exec-plan

> Claude skill for creating, implementing, and managing execution plans (ExecPlans) —
> self-contained design documents that guide implementation of features and system
> changes.

**Version:** `0.8.0`

## Overview

Installs an `exec-plan` skill into the project's `agents/skills/` tree. The `link-skill`
dependency exposes the skill under `.claude/skills/` (for Claude Code) and
`.agents/skills/` (for other agent harnesses) via relative symlinks. When
`intentions.enabled` is true, appends an intention-tracking section to the skill's
`SKILL.md` so ExecPlans carry `Intention:` trailers in their commits.

## Variables

| Name | Type | Default | Required | Validation | Description |
|------|------|---------|----------|------------|-------------|
| `skill.name` | `text` | `exec-plan` | yes | `[a-z][a-z0-9-]*` | Name of the skill directory |
| `intentions.enabled` | `bool` | `false` | no | — | Enable intention tracking — reuses an existing plan Intention ID or prompts when missing, and adds an `Intention:` trailer to commits |

## Prompts

The following values are asked interactively (unless supplied via `--var`):

- **`intentions.enabled`** — Enable intention tracking for commits?

## Dependencies

This module pulls in:

- **`agent-gitignore`** — ensures `.claude/`, `.agents/`, and `CLAUDE.local.md` are
  ignored. Replaces the older transitive `claude-gitignore` dep with a single
  superset that covers both agent-harness directories.
- **`link-skill`**
  - Variable bindings:
    - `skill.name` = `exec-plan`

## Exports

Variables this module exposes to parent modules:

- `skill.name`

## Generated Files

When run, this module writes:

- `agents/skills/{{skill.name}}/SKILL.md` — strategy: `template`
- `agents/skills/{{skill.name}}/PLANS.md` — strategy: `copy`
- `agents/skills/{{skill.name}}/ADR.md` — strategy: `copy`
- `agents/skills/{{skill.name}}/init-plan.ts` — strategy: `copy`
- `agents/skills/{{skill.name}}/SKILL.md` — strategy: `copy`
  - Applied when: `Eq intentions.enabled true`
  - Patch mode: `append-section`

`dest` may contain `{{var}}` placeholders; they are resolved at run time. The
`init-plan.ts` script is invoked by the skill at plan-creation time (via Bun) to
deterministically pick the next sequential number, slugify the title, and emit the
plan file with YAML frontmatter and the canonical skeleton.

`ADR.md` is the shared ADR contract used by both planning skills. It preserves the
repository's existing convention when no profile is configured; for a profiled OKF
bundle it governs stable handle allocation, strict validation, and canonical Mori
references across repositories.

## Migrations

Author-declared migrations applied via `seihou migrate exec-plan`:

- **`0.1.3` → `0.2.0`** — moves the skill from `claude/skills/` to `agents/skills/`,
  refreshes the `.claude/skills/exec-plan` symlink to the new path, and creates a new
  `.agents/skills/exec-plan` symlink. After migration the older `claude-skill-link`
  manifest entry is stale; re-running `seihou run exec-plan` (or any module that
  depends on it) reconciles the dependency tree to the new `link-skill` dep.

  Operations:
  - `move-file claude/skills/exec-plan/SKILL.md → agents/skills/exec-plan/SKILL.md`
  - `move-file claude/skills/exec-plan/PLANS.md → agents/skills/exec-plan/PLANS.md`
  - `run rm -f .claude/skills/exec-plan`
  - `run mkdir -p .claude/skills .agents/skills`
  - `run ln -sfn ../../agents/skills/exec-plan .claude/skills/exec-plan`
  - `run ln -sfn ../../agents/skills/exec-plan .agents/skills/exec-plan`

- **`0.7.0` → `0.8.0`** — installs and runs the adaptive
  `adopt-architecture-decisions` blueprint from `okf-profiles`. Repositories with
  existing ADRs are reconciled to the shared profile, stable handles, validation,
  and Mori registration; repositories without ADRs complete this migration as a
  no-op. The blueprint runs through the configured Seihou agent provider and adapts
  to repository-local history and check conventions. It uses Seihou's
  non-interactive blueprint batch mode and therefore requires a Seihou release
  that supports `seihou agent run --batch`.

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

Migrate an existing project from a previous version:

```bash
seihou migrate exec-plan --dry-run   # preview the chain
seihou migrate exec-plan             # apply
```

## See Also

- `module.dhall` — full module definition and authoritative source
- `files/` — template sources
- `master-plan` — coordination skill that depends on this module
- `link-skill` — symlink infrastructure (transitive dependency)
- `agent-gitignore` — gitignore rules for `.claude/` and `.agents/`
