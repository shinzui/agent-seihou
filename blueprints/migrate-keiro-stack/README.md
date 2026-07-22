# migrate-keiro-stack

> Inspect a Haskell/PostgreSQL project and migrate it to a coherent pg-migrate, PGMQ,
> Kiroku, Keiro, Kioku, Shibuya, and Settei standards. For projects with an existing Nix build, the
> agent adopts the maintained haskell-nix package set and removes proven-redundant cohort
> overrides; projects without Nix remain Cabal-only. The agent selects a guarded disposable
> reset or a backup-and-restored-clone persistent cutover from database evidence, composes
> the ordered migration plan, adopts the fleet vertical structure and Settei configuration,
> validates live behavior, and keeps
> destructive actions operator-approved.

**Version:** `0.2.0`

**Kind:** Blueprint (agent-driven — run with `seihou agent run`, not `seihou run`)

## Overview

This blueprint launches an interactive coding agent that discovers the target repository's actual
dependencies, build paths, runtime APIs, migration ownership, and database history before
implementing an upgrade. For Nix-enabled targets it adopts the current Mori-located shared
`haskell-nix` package set while preserving necessary application overrides; for targets without Nix
it keeps the migration Cabal-only. It supports either a guarded disposable reset or a
backup-and-restored-clone persistent-data cutover.
It also performs behavior-preserving vertical-module and configuration migrations before database
classification.

## Variables

| Name | Type | Default | Required | Validation | Description |
|------|------|---------|----------|------------|-------------|
| `database.policy` | `text` | `ask` | yes | `(ask|disposable|preserve)` | Database safety policy. `ask` classifies from read-only evidence and asks only when intent remains ambiguous; `disposable` permits a confirmed local/unshared/non-production reset; `preserve` requires backup and restored-clone proof before writes. |

## Baseline

This blueprint declares no base modules.

## Reference Files

Mounted read-only and listed in the agent's prompt as adaptable source material:

- `files/cohort-and-runtime-reference.md` — Release-cohort baseline, Mori-first dependency discovery, conditional shared haskell-nix integration, migration ownership order, Cabal/Nix alignment, and Kiroku/Keiro/Shibuya/PGMQ/Kioku runtime adaptation checklist.
- `files/pg-migrate-implementation-reference.md` — Application-authoring guide for strict manifests, embedded migration components, the ordered complete plan, standard CLI integration, history import, testing, verification, and forward-only recovery.
- `files/disposable-database-fast-path.md` — Short path for an explicitly confirmed local, unshared, non-production database that may be erased, rebuilt, verified, reapplied with zero work, and smoke-tested.
- `files/persistent-database-cutover.md` — Fail-closed runbook for data-bearing databases: inventory, classification, backup, writer quiescence, restored-clone rehearsal, evidence-backed history import, verification, cutover, soak, and restore rollback.
- `files/vertical-structure-refactor.md` — Behavior-preserving guide for adopting the fleet six-package Generated/Holes vertical-slice structure.
- `files/settei-migration.md` — Behavior-preserving guide for adopting Settei layering, diagnostics, and rollout gates.

## What the agent produces

The agent selects a source-verified cohort and, when the target already uses Nix, integrates the
shared `haskell-nix` channel that matches Cabal provenance, removes only proven-redundant cohort
overrides, and validates any temporary local override plus the portable locked input. It adapts the
target's Kiroku, Keiro, Shibuya, PGMQ, and Kioku runtime APIs and composes the ordered
`pgmq -> kiroku -> keiro -> kioku -> application` migration plan. It classifies the database from
read-only evidence and follows either a confirmed disposable reset or a backup-and-restored-clone
persistent cutover, with strict verification, zero-work reapplication, live assertions, and
application smoke testing before legacy migration machinery is removed.
Before classification it moves modules into the fleet vertical structure and migrates configuration
to Settei without changing behavior, proving both transformations with before/after tests and
resolved-configuration evidence.

## Usage

Run in the target repository:

```bash
seihou agent run migrate-keiro-stack
```

With variable overrides, or skipping the baseline:

```bash
seihou agent run migrate-keiro-stack --var database.policy=disposable
seihou agent run migrate-keiro-stack --var database.policy=preserve
seihou agent run migrate-keiro-stack --no-baseline
```

Print the resolved agent system prompt without launching the agent (no side effects):

```bash
seihou agent --debug run migrate-keiro-stack --no-baseline
```

## Tags

`haskell`, `postgresql`, `pg-migrate`, `keiro`, `kiroku`, `kioku`, `shibuya`, `pgmq`, `nix`, `settei`, `vertical-slice`

## See Also

- `blueprint.dhall` — full blueprint definition and authoritative source
- `prompt.md` — the agent task prompt
- `files/` — read-only reference material
