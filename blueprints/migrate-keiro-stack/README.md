# migrate-keiro-stack

> Inspect a Haskell/PostgreSQL project and migrate it to a coherent pg-migrate, PGMQ,
> Kiroku, Keiro, Kioku, and Shibuya cohort with database-state-aware safety gates.

**Version:** `0.1.0`

**Kind:** Blueprint (agent-driven — run with `seihou agent run`, not `seihou run`)

## Overview

This blueprint launches an interactive coding agent that discovers the target repository's actual
dependencies, runtime APIs, migration ownership, and database history before implementing an
upgrade. It is for maintainers who need either a guarded disposable reset or a backup-and-restored-
clone persistent-data cutover, with destructive work kept behind explicit operator approval.

## Variables

| Name | Type | Default | Required | Validation | Description |
|------|------|---------|----------|------------|-------------|
| `database.policy` | `text` | `ask` | yes | `(ask|disposable|preserve)` | Database safety policy. `ask` classifies from read-only evidence and asks only when intent remains ambiguous; `disposable` permits a confirmed local/unshared/non-production reset; `preserve` requires backup and restored-clone proof before writes. |

## Baseline

This blueprint declares no base modules. Running with `--no-baseline` is therefore an explicit
equivalent and does not alter the migration workflow.

## Reference Files

Mounted read-only by Seihou v0.4 and listed in the agent's prompt as adaptable source material
(older compatible Seihou versions may list them without mounting them):

- `files/cohort-and-runtime-reference.md` — Release-cohort baseline, Mori-first dependency discovery, migration ownership order, Cabal/Nix alignment, and Kiroku/Keiro/Shibuya/PGMQ/Kioku runtime adaptation checklist.
- `files/pg-migrate-implementation-reference.md` — Application-authoring guide for strict manifests, embedded migration components, the ordered complete plan, standard CLI integration, history import, testing, verification, and forward-only recovery.
- `files/disposable-database-fast-path.md` — Short path for an explicitly confirmed local, unshared, non-production database that may be erased, rebuilt, verified, reapplied with zero work, and smoke-tested.
- `files/persistent-database-cutover.md` — Fail-closed runbook for data-bearing databases: inventory, classification, backup, writer quiescence, restored-clone rehearsal, evidence-backed history import, verification, cutover, soak, and restore rollback.

## What the agent produces

The agent aligns Cabal and Nix on a source-verified cohort, adapts the target's Kiroku, Keiro,
Shibuya, PGMQ, and Kioku runtime APIs, and composes the ordered
`pgmq -> kiroku -> keiro -> kioku -> application` migration plan. It classifies the database from
read-only evidence and either requests a final confirmation for a proven disposable reset or
requires backup, writer quiescence, and successful restored-clone rehearsal for persistent data.
Both paths require strict verification, a second zero-work apply, live schema/data assertions, and
a representative application smoke before legacy migration machinery can be removed.

The workflow requires a tool-capable interactive `claude-cli` (default) or `codex-cli` session.
Commands such as `mori`, builds, database inspection, backup, and migration execution may prompt
for deliberate tool approval; the API-only `anthropic` and `openai` providers are not suitable for
this interactive run.

## Usage

Run in the target repository with the default evidence-driven policy:

```bash
seihou agent run migrate-keiro-stack
```

Select an explicit database policy, or state the no-baseline behavior:

```bash
seihou agent run migrate-keiro-stack --var database.policy=disposable
seihou agent run migrate-keiro-stack --var database.policy=preserve
seihou agent run migrate-keiro-stack --no-baseline
```

`disposable` still requires proof that the exact database is local, unshared, and non-production,
plus confirmation immediately before erasure. `preserve` forbids writes to a data-bearing target
until backup and restored-clone gates pass. If observed evidence contradicts either policy, the
agent stops rather than switching paths silently.

Print the resolved agent system prompt without launching the provider:

```bash
seihou agent --debug run migrate-keiro-stack --no-baseline
```

Seihou v0.4 records successful debug-run provenance in `.seihou/manifest.json`; use a disposable
temporary registry copy when the render check must leave the target worktree untouched.

## Tags

`haskell`, `postgresql`, `pg-migrate`, `keiro`, `kiroku`, `kioku`, `shibuya`, `pgmq`

## See Also

- `blueprint.dhall` — full blueprint definition and authoritative source
- `prompt.md` — the agent task prompt
- `files/` — read-only reference material
