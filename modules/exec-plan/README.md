# exec-plan

> Claude skill for creating, implementing, and managing execution plans (ExecPlans) —
> self-contained design documents that guide implementation of features and system
> changes.

**Version:** `0.14.0`

## Overview

Installs an `exec-plan` skill into `agents/skills/{{skill.name}}/`. Each source-generating
module declares its own relative discovery links under `.claude/skills/`,
`.codex/skills/` and `.agents/skills/`, using the same resolved source-name variable.
The default composition exposes both planning skills at all six destinations.
Intention tracking remains optional and preserves the existing planning workflow.

Since `0.9.0` the skill also tracks plan provenance — which model authored a plan, which
models revised it, and which models reviewed it — in the plan's YAML frontmatter, and
adds a `review` mode that audits a plan against `PLANS.md` and records its verdict.

Since `0.11.0`, Progress checkboxes represent verifiable milestones or substantial
deliverables. The skill updates plans at milestone completion, material changes, or
handoff, and avoids checkboxes for routine actions. Status reports describe milestone
state rather than treating checkbox counts as a measure of effort.

Since `0.12.0`, implementation follows accepted outcomes through cohesive changes and
proportionate validation. Uncertain interfaces receive an early interaction check when
needed; new requirements remain explicit scope decisions. Existing acceptance and
applicable evidence are preserved.

Since `0.14.0`, implementation records friction — the cost of doing the work: a document,
interface, tool, environment, or house process that cost material effort — as it occurs,
in a `docs/friction-log/` OKF bundle governed by `coordination.frictionLog` from
`mori://shinzui/okf-profiles`, through the bundled `record-friction.ts` script, and
triages the entries at completion. `FRICTION.md` is the shared contract, and the
master-plan skill follows it for child plans.

## Checkout links and adoption

Discovery links are manifest-owned checkout declarations. Sources remain in
`agents/skills/` and are generated in the same application; links also work under
`--no-commands`. Real objects at destinations cause safe refusal. The complete
adoption workflow is verified with source revision
`c3cbd9bd202e87d6fd7fc0ede1d997d2c2140e0b` of `mori://shinzui/seihou`.
The supporting runtime changes are not yet available as a versioned Hackage release;
0.11.0.0 is proposed. The older 0.10.1.0 release does not include those changes.

A maintainer of an existing project uses the recorded root application:

```sh
seihou update exec-plan
```

Review and accept the ordinary preview. Update fetches the recorded source and
dependencies, reuses saved inputs, prepares older schemas and previews eligible
tracked-link adoption. No prerequisite installation list or manual index edit is
needed. If exec-plan belongs to master-plan, update master-plan as the root.
Commit manifest, baselines, source assets and ignore rules. Teammates receive that
commit and run one command, without producer installation or configuration:

```sh
seihou sync
```

Sync restores only the recorded declarations and does not fetch or upgrade modules.
Repeating it repairs deleted or wrongly targeted links without changing shared state.

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

- **`agent-gitignore`** — ensures `.claude/`, `.codex/`, `.agents/`, and `CLAUDE.local.md` are
  ignored. Replaces the older transitive `claude-gitignore` dep with a single
  superset that covers all three discovery directories.

## Exports

Variables this module exposes to parent modules:

- `skill.name`

## Generated Files

When run, this module writes:

- `agents/skills/{{skill.name}}/SKILL.md` — strategy: `template`
- `agents/skills/{{skill.name}}/PLANS.md` — strategy: `copy`
- `agents/skills/{{skill.name}}/ADR.md` — strategy: `copy`
- `agents/skills/{{skill.name}}/init-plan.ts` — strategy: `copy`
- `agents/skills/{{skill.name}}/record-provenance.ts` — strategy: `copy`
- `agents/skills/{{skill.name}}/provenance-model.ts` — strategy: `copy`
- `agents/skills/{{skill.name}}/PROVENANCE.md` — strategy: `copy`
- `agents/skills/{{skill.name}}/FRICTION.md` — strategy: `copy`
- `agents/skills/{{skill.name}}/record-friction.ts` — strategy: `copy`
- `agents/skills/{{skill.name}}/SKILL.md` — strategy: `copy`
  - Applied when: `Eq intentions.enabled true`
  - Patch mode: `append-section`

`dest` may contain `{{var}}` placeholders; they are resolved at run time. The
`init-plan.ts` script is invoked by the skill at plan-creation time (via Bun) to
deterministically pick the next sequential number, slugify the title, and emit the
plan file with YAML frontmatter and the canonical skeleton.

`record-provenance.ts` appends one provenance entry to a plan's YAML frontmatter — a
`review` (with a verdict of `approved`, `changes-requested`, or `comments`) or a
`revision` (with a mode of `implement`, `update`, `discuss`, or `other`). It only ever
appends, so several models can review the same plan without clobbering one another's
records, and it is shared with the `master-plan` skill, which records MasterPlan
provenance through this same script. Plans written before `0.9.0` have no `provenance`
block; the script adds one holding just the new entry and never fabricates a
`created_by` record.

Since `0.10.0`, both initializers and the revision/review writer require a verified
model ID or explicit current-session metadata. The shared helper supports Codex
and Claude Code transcripts, checks session/agent identity, and refuses stale
models after a switch or a new turn without model metadata. `unknown` requires
`--allow-unknown --unknown-reason "<why discovery failed>"`; the reason is recorded
in the entry's note. `PROVENANCE.md` documents discovery and historical corrections.
Explicit IDs continue to support other harnesses.

Run the upstream regression suite with `bun test`. The provenance suite is self-contained;
the friction suite spawns `okf` and bootstraps a bundle from an okf-profiles checkout, which
it finds through `OKF_PROFILES_PACKAGE` or `mori path mori://shinzui/okf-profiles`, and
reports itself skipped when either is unavailable.

`ADR.md` is the shared ADR contract used by both planning skills. It preserves the
repository's existing convention when no profile is configured; for a profiled OKF
bundle it governs stable handle allocation, strict validation, and canonical Mori
references across repositories.

`FRICTION.md` is the shared friction-log contract used by both planning skills: what
counts as friction and what does not, the threshold for recording it, how it differs from
Surprises & Discoveries, bug reports, and improvement requests, and how entries are
triaged and cited. `record-friction.ts` is the only writer. On first use it bootstraps
the bundle with `okf profile init`, pinning `coordination.frictionLog` from okf-profiles
`v0.23.0`, the first release that exports the profile; before that tag is published, pass
`--registry <okf-profiles-checkout>/package.dhall` and repin afterwards. Each `log` call
allocates the next `FRIC-N` handle with `okf id next`, writes the entry, appends to the
bundle's `log.md`, regenerates `index.md`, and validates strictly; each `update` call
changes the triage status, appends an `amended` record so `generated` keeps who observed
the friction, and validates again. The script derives `origin` from `mori.dhall` through
`mori show --json` and accepts the same identity options as the provenance scripts. It
requires `okf` 0.10.0.0 or later for `okf profile init`.

## Migrations

The shell link operations below belong to historical source moves. Current setup
uses its own checkout declarations; these migrations remain intact for
older consumers and do not substitute for applying the new declarations.

Author-declared migrations applied via `seihou migrate exec-plan`:

- **`0.1.3` → `0.2.0`** — moves the skill from `claude/skills/` to `agents/skills/`,
  refreshes the `.claude/skills/exec-plan` symlink to the new path, and creates a new
  `.agents/skills/exec-plan` symlink. After migration the older `claude-skill-link`
  manifest entry is stale; re-running `seihou run exec-plan` (or any module that
  depends on it) reconciles the dependency tree to the new `link-skill` dep.

  Operations:
  - `move-file claude/skills/exec-plan/SKILL.md → agents/skills/exec-plan/SKILL.md`
  - `move-file claude/skills/exec-plan/PLANS.md → agents/skills/exec-plan/PLANS.md`
  - `run rm -rf .claude/skills/exec-plan claude/skills/exec-plan`
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
  that supports `seihou agent run --batch`. The migration independently
  type-checks the installed profile and runs strict profile/log validation when
  ADR records exist, so a partial agent run cannot advance the module version.

No migration is declared for `0.8.0` → `0.9.0`. Plan provenance is additive and
optional: existing plans keep parsing unchanged with no `provenance` key, and each model
records its own entries as it touches a plan. Re-run `seihou run exec-plan` to pick up
the new `record-provenance.ts` script and the refreshed `SKILL.md` and `PLANS.md`.

No data migration is needed for `0.9.0` → `0.10.0`: existing provenance remains
unchanged. Re-run the module to install the shared helper and discovery guide with
the updated scripts. New initializer invocations must now supply identity; scripts
that passed `unknown` must also supply the explicit fallback flag and reason.

No migration is declared for `0.13.0` → `0.14.0`. The friction-log bundle is created
on first use by `record-friction.ts`, so existing repositories gain it the first time an
implementation records friction. Re-run the module to install `FRICTION.md` and the
script, and add the bundle to `mori.dhall` when it appears, as `FRICTION.md` describes.

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
- `link-skill` — standalone module for exposing other project skill sources
- `agent-gitignore` — gitignore rules for `.claude/` and `.agents/`
