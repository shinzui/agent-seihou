# master-plan

> Claude skill for creating and managing master plans (MasterPlans) — coordination
> documents that decompose large initiatives into multiple ExecPlans with dependencies
> and integration points.

**Version:** `0.10.0`

## Overview

Installs a `master-plan` skill into the project's `agents/skills/` tree, pairing it with
an `exec-plan` skill (pulled in as a dependency). The `link-skill` dependency exposes
both skills under `.claude/skills/` (for Claude Code) and `.agents/skills/` (for other
agent harnesses) via relative symlinks. MasterPlans use the exec-plan dependency's
shared `ADR.md` contract for profiled OKF bundles and canonical cross-repository Mori
references.

Since `0.9.0` MasterPlans and their child ExecPlans track provenance — which model
authored the document, which models revised it, and which models reviewed it — in YAML
frontmatter, and the skill gains a `review` mode that audits a decomposition and records
its verdict. Entries are written by the exec-plan dependency's `record-provenance.ts`.

## Variables

| Name | Type | Default | Required | Validation | Description |
|------|------|---------|----------|------------|-------------|
| `mp.skill.name` | `text` | `master-plan` | yes | `[a-z][a-z0-9-]*` | Name of the master-plan skill directory |
| `exec-plan.skill.name` | `text` | `exec-plan` | yes | `[a-z][a-z0-9-]*` | Name of the exec-plan skill directory (for cross-references in templates) |
| `intentions.enabled` | `bool` | `false` | no | — | Enable intention tracking — reuses an existing plan Intention ID or prompts when missing, and adds an `Intention:` trailer to commits |

## Prompts

The following values are asked interactively (unless supplied via `--var`):

- **`intentions.enabled`** — Enable intention tracking for commits?

## Dependencies

This module pulls in:

- **`agent-gitignore`** — ensures `.claude/`, `.agents/`, and `CLAUDE.local.md` are
  ignored. Replaces the older transitive `claude-gitignore` dep with a single
  superset that covers both agent-harness directories.
- **`exec-plan`**
  - Variable bindings:
    - `skill.name` = `exec-plan`
- **`link-skill`**
  - Variable bindings:
    - `skill.name` = `master-plan`

## Exports

Variables this module exposes to parent modules:

- `mp.skill.name`

## Generated Files

When run, this module writes:

- `agents/skills/{{mp.skill.name}}/SKILL.md` — strategy: `template`
- `agents/skills/{{mp.skill.name}}/MASTERPLAN.md` — strategy: `template`
- `agents/skills/{{mp.skill.name}}/init-masterplan.ts` — strategy: `template`
- `agents/skills/{{mp.skill.name}}/SKILL.md` — strategy: `copy`
  - Applied when: `Eq intentions.enabled true`
  - Patch mode: `append-section`

`dest` may contain `{{var}}` placeholders; they are resolved at run time. The
`init-masterplan.ts` script is invoked by the skill at MasterPlan creation time
(via Bun) to deterministically pick the next sequential number, slugify the title,
and emit the plan file with YAML frontmatter and the canonical skeleton. Pass
`--model` (and optionally `--harness`) so the frontmatter records the authoring model.
Child ExecPlans are created via the exec-plan skill's own `init-plan.ts`.

This module installs no provenance script of its own: reviews and revisions of a
MasterPlan are recorded with `agents/skills/{{exec-plan.skill.name}}/record-provenance.ts`,
installed by the exec-plan dependency.

Since `0.10.0`, the initializer also imports the dependency's `provenance-model.ts`.
Its import is templated using `exec-plan.skill.name`, including custom skill names.
All writers require verified identity, support explicit Codex and Claude Code
session files, and guard `unknown` behind an opt-in flag and a recorded reason.
Follow the dependency's shared `PROVENANCE.md` discovery procedure.

## Migrations

Author-declared migrations applied via `seihou migrate master-plan`:

- **`0.1.0` → `0.2.0`** — moves the skill from `claude/skills/` to `agents/skills/`,
  refreshes the `.claude/skills/master-plan` symlink to the new path, and creates a new
  `.agents/skills/master-plan` symlink. After migration the older `claude-skill-link`
  manifest entry is stale; re-running `seihou run master-plan` reconciles the dependency
  tree to the new `link-skill` dep.

  Operations:
  - `move-file claude/skills/master-plan/SKILL.md → agents/skills/master-plan/SKILL.md`
  - `move-file claude/skills/master-plan/MASTERPLAN.md → agents/skills/master-plan/MASTERPLAN.md`
  - `run rm -f .claude/skills/master-plan`
  - `run mkdir -p .claude/skills .agents/skills`
  - `run ln -sfn ../../agents/skills/master-plan .claude/skills/master-plan`
  - `run ln -sfn ../../agents/skills/master-plan .agents/skills/master-plan`

No migration is declared for `0.8.0` → `0.9.0`. Plan provenance is additive and
optional: existing MasterPlans keep parsing unchanged with no `provenance` key. Re-run
`seihou run master-plan` to pick up the refreshed `SKILL.md` and `MASTERPLAN.md`, and
`record-provenance.ts` through the exec-plan dependency.

For `0.9.0` → `0.10.0`, re-run `master-plan` together with its `exec-plan` dependency
to install the helper and guide alongside the updated scripts. Existing plans need
no migration. New initializer invocations must supply identity; an unknown model
also requires `--allow-unknown --unknown-reason "<why discovery failed>"`.

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

Migrate an existing project from a previous version:

```bash
seihou migrate master-plan --dry-run   # preview the chain
seihou migrate master-plan             # apply
```

## See Also

- `module.dhall` — full module definition and authoritative source
- `files/` — template sources
- `exec-plan` — companion ExecPlan skill (transitive dependency)
- `link-skill` — symlink infrastructure (transitive dependency)
- `agent-gitignore` — gitignore rules for `.claude/` and `.agents/`
