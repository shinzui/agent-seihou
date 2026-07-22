# Migrate this project to the pg-migrate Keiro stack

Database policy: {{database.policy}}

Before any repository inspection or tool call, verify that the rendered database policy is exactly
`ask`, `disposable`, or `preserve`. If it is any other value, stop immediately, report that
`database.policy` is invalid, and make no changes or external calls. This prompt-level guard is
required even when the launching Seihou version claims to validate the variable.

Inspect and migrate the current Haskell/PostgreSQL project to one coherent released pg-migrate,
PGMQ, Kiroku, Keiro, Kioku, and Shibuya cohort. Adapt the runtime APIs, compose the production
migration plan, and prove the database path selected from evidence. Work autonomously through safe,
read-only and implementation steps. Ask only when database ownership or destructive intent cannot
be established, or when the operator must approve an external write.

This run requires a tool-capable interactive provider: the default `claude-cli`, or `codex-cli`.
Do not use the `anthropic` or `openai` API providers for this interactive workflow. Commands beyond
the normal Seihou/Git/file tools—especially `mori`, `cabal`, `nix`, `psql`, `pg_dump`, database
lifecycle commands, and the migration executable—may request interactive approval. Treat approval
as an operator safety gate. Present destructive commands with enough sanitized target context for a
deliberate choice.

## Reference handling

Six supplemental references are listed with this blueprint:

- `cohort-and-runtime-reference.md` for release selection and runtime APIs;
- `pg-migrate-implementation-reference.md` for application plan authoring;
- `disposable-database-fast-path.md` for a confirmed resettable database;
- `persistent-database-cutover.md` for data-bearing cutover and recovery;
- `vertical-structure-refactor.md` for behavior-preserving module moves; and
- `settei-migration.md` for behavior-preserving configuration adoption.

If Seihou reports a readable reference directory, open the relevant files before using their deeper
examples. Otherwise continue from the complete safety workflow in this prompt. Ask the operator to
paste a reference only when its deeper detail is material to a blocked decision. Never fabricate a
reference's contents or claim to have read a file that is not reachable.

## Non-negotiable working rules

Read all repository-local instructions before editing. Preserve existing and unrelated changes.
Work on the current branch unless the operator explicitly requests another; do not create a feature
branch by default. Follow the target's commit format. Offer a commit only after the applicable
checks pass, and never push without explicit authorization.

Use Mori before relying on dependency memory. Never search `/nix/store`, and never traverse the
filesystem root. Scope searches to the current project and paths Mori explicitly reports.

Do not infer that a database is disposable from project age, team size, migration count, an empty
Git history, or the presence of a local development setup. Database state and ownership decide the
path.

Never:

- run speculative `up`, repair, history import, or schema bootstrap while classifying a database;
- write to a production or data-bearing database automatically;
- initialize the pg-migrate target ledger before persistent-state inventory and backup gates;
- hide schema creation inside normal application startup after explicit migration ownership;
- copy component or ledger counts from an example, Mori, Rei, Kioku, or this prompt;
- edit, delete, relabel, or manually backfill rows in `pgmigrate.migrations`;
- bypass a checksum, position, kind, transaction-mode, prefix, or unknown-row failure;
- delete old migration engines before the selected database proof and application smoke pass;
- guess dependency imports, effect rows, or constructors without selected source;
- treat strict `verify` as a live-schema diff;
- push commits or perform external deployment without authorization.

## Phase 1: Establish repository and dependency facts

Start with working-tree and project identity:

```bash
git status --short --branch
```

If `mori.dhall` exists, run:

```bash
mori show --full
mori registry list
```

Discover the dependency projects and packages:

```bash
mori registry search pg-migrate
mori registry search pgmq
mori registry search kiroku
mori registry search keiro
mori registry search kioku
mori registry search shibuya
mori registry docs shinzui/keiro-runtime-patterns
mori registry docs shinzui/haskell-jitsurei
```

The last two projects publish the prescriptive runtime, architecture, configuration, and HTTP
standards on which the migrated service must land. Read the relevant DocRefs before editing.

If the target has an active Nix build, also run:

```bash
mori registry search haskell-nix
```

Treat `flake.nix`, Nix files referenced by CI or project documentation, and maintained Nix build or
development-shell commands as evidence that Nix is active. A stray or explicitly retired Nix file
is not enough; record that distinction.

For every candidate selected, run `mori registry show <qualified-project> --full` and
`mori registry docs <qualified-project>`, then read its source and relevant local documentation at
the reported path. For a Nix-enabled target, this includes the selected `haskell-nix` project and
its consumer-integration documentation. If a dependency is not registered, record the failed lookup
and use the target's lockfiles/package metadata plus an explicitly located checkout or published
source. Do not guess an API or search `/nix/store`.

Inventory, with repository-relative paths:

- Cabal packages, `cabal.project`, package constraints, index-state, and source repositories;
- Nix flakes, inputs, overlays, package source overrides, selected `haskell-nix` channel and locked
  revision when present, and build/check commands;
- current pg-migrate/PGMQ/Kiroku/Keiro/Kioku/Shibuya/Keiki/Shikumi versions and source revisions;
- workstation-local paths, stale Git pins, and places where Cabal and Nix resolve different code;
- every migration directory, manifest, embedded SQL module, and historical payload source;
- every Codd, hasql-migration, pg-migrate, package-specific, and application migration command;
- every schema writer in application startup, tests, worker startup, queue setup, and helpers;
- runtime entry points using Kiroku, Keiro commands, Shibuya handlers, PGMQ adapters, or Kioku;
- test, formatting, build, Nix, and application smoke commands;
- database URLs by operational role, sanitized so credentials never enter logs;
- legacy and target ledger shapes/rows, live schemas, table locations, row counts, extensions,
  owners, grants, and critical data invariants.

Determine whether the application owns SQL and therefore needs its own migration component. Record
any helper, such as TypeID, that has no native component and must remain outside the plan. Database
preflight must run before any such remaining writer.

Preserve existing migration filenames and exact payload bytes before moving or formatting them.
Inspect actual manifests and source ledgers to derive counts and supported import mappings.

## Phase 2: Select a coherent cohort

Use a later coherent release set when current Mori-located source proves it compatible. Otherwise
use this known-good Hackage baseline, verified 2026-07-22, with `index-state` no earlier than
`2026-07-22T18:04:31Z`:

| Area | Packages | Version |
| --- | --- | --- |
| pg-migrate | `pg-migrate`, CLI, embed, and required import adapters | `1.1.0.0` |
| PGMQ | `pgmq-core`, `pgmq-config`, `pgmq-effectful`, `pgmq-hasql`, `pgmq-migration` | `0.4.0.1` |
| Keiro | `keiro`, `keiro-core`, `keiro-migrations`, `keiro-pgmq` | `0.3.0.0` |
| Kiroku | `kiroku-store` | `0.3.1.0` |
| Kiroku tools | `kiroku-store-migrations`, `kiroku-cli`, `kiroku-metrics`, `kiroku-otel` | `0.3.0.0`, `0.2.0.0`, `0.1.0.1`, `0.2.0.1` |
| Kiroku/Shibuya | `shibuya-kiroku-adapter` | `0.4.0.0` |
| Kioku | `kioku-api`, `kioku-core`, `kioku-migrations` | `0.1.0.0` |
| Keiki | `keiki`, `keiki-codec-json` | `0.2.0.0` |
| Shibuya | `shibuya-core`, `shibuya-metrics` | `0.8.0.1` |
| Shibuya/PGMQ | `shibuya-pgmq-adapter` | `0.12.0.0` |
| Shikumi | `shikumi`, `shikumi-cache`, `shikumi-trace` | `0.3.0.1`, `0.1.2.1`, `0.2.0.1` |
| Notifications | `hasql-notifications` | `0.2.5.0` |
| Settei | `settei`, env, formats, optparse-applicative, and Kubernetes adapters | `0.2.0.0` |

Treat this as a reproducible fallback, not an eternal “latest.” If selecting a successor, prove the
complete graph and record exact versions, index-state or source revisions, and why they form a
cohort.

Nix support is conditional. If the target has no active Nix build, do not introduce one solely for
this migration; complete and validate the Cabal path. If Nix is active, prefer the current
Mori-located `shinzui/haskell-nix` package set over recreating first-party source pins or shared GHC
compatibility fixes in the application. Read the selected checkout's current outputs before editing.
Choose its GitHub channel for the locked first-party source revisions, including unpublished
packages, or its Hackage channel for the recorded published releases, and make that provenance agree
with the Cabal source policy.

Use the named `lib.haskellExtensions.<channel>` output with `composeExtensions` when genuine
target-specific Haskell overrides remain; if none remain, the named `overlays.<channel>` output is
the simpler integration. Remove an existing cohort override only after the selected shared channel
is proven to supply the required package source, version, and compatibility behavior. Preserve
unrelated application overrides and compose them after the shared extension. Do not call
`.override { overrides = ...; }` on a Haskell package set patched through the shared overlay,
because that replaces the shared overrides.

Commit a portable flake input and lock revision according to target policy; never commit the
Mori-reported workstation path. When the local `haskell-nix` checkout is newer than the locked
input or is needed to prove the migration before publication, exercise the target's normal Nix
build with `--override-input haskell-nix path:<mori-reported-path>` without rewriting the lock, then
validate the portable locked input as soon as it is available.

When Nix is active, make Cabal and Nix resolve the same sources. Remove stale cohort paths/pins only
after identifying and validating their replacement, and preserve unrelated application pins. Build
the complete application graph, not just the migration executable.

## Phase 3: Adapt runtime APIs from selected source

Use these names as search anchors, not as permission to assume a module or signature.

### Kiroku

Adopt process-scoped `KirokuStoreResource` ownership at long-lived entry points. Replace ad hoc
`withStore`/`runStoreIO` lifecycles only after reading the selected Kiroku resource API. Acquire one
store for the process, interpret operations against it, and configure runtime schema initialization
off after the explicit plan owns the framework schema.

### Keiro

Keiro command runners and relevant projection/router/process-manager boundaries accept
`ValidatedEventStream`. Regenerate matching DSL output or construct validated hand-authored streams
at application wiring. Handle validation warnings deliberately; do not use unchecked construction
to silence type errors.

### Shibuya

Adapt application setup to `AppConfig` and `defaultAppConfig` from selected source. Handler-facing
values are `Message`, not the framework's acknowledgement-owning ingestion type. Update handler
patterns and application runner calls from the compiler errors after reading the selected facade.

### Shibuya PGMQ Adapter and Keiro PGMQ

Construct `PgmqAdapterEnv` from the Hasql pool with `mkPgmqAdapterEnv`. In the baseline,
`pgmqAdapter` takes this environment and returns `Either PgmqConfigError ...`; handle the error
before starting processors. Add `Reader PgmqAdapterEnv` to Keiro PGMQ processor effect rows and
preserve the selected source's `Pgmq`, tracing, runtime-error, and IO constraints.

### Kioku

Register Kioku read models once during runtime acquisition. After a composed migration succeeds,
run the selected read-model registry reconciliation before traffic resumes. In the baseline,
`reconcileReadModelRegistry` is idempotent and belongs at migration time, not racing in each normal
startup. Read-only `status` and `verify` must not reconcile.

Compile after each coherent adaptation slice. Let compiler errors identify remaining call sites,
but use selected source to decide the fix.

## Phase 4: Author the native migration plan

Each migration owner exports a `MigrationComponent` built from a strict checked-in manifest. A
module that calls `embedMigrationManifest` on GHC 9.12 includes:

```haskell
{-# OPTIONS_GHC -fplugin=Database.PostgreSQL.Migrate.Embed.RecompilePlugin #-}
```

Preserve exact historical bytes and filenames. Manifest format is one top-level lowercase `.sql`
filename per line in immutable order. Append corrections; never edit, rename, remove, or reorder an
entry that may have been applied.

Resolve the components from the selected releases and compose this visible dependency order:

```text
pgmq -> kiroku -> keiro -> kioku -> application
```

PGMQ owns queue infrastructure. Kiroku owns the event-store schema. Keiro owns framework schema on
Kiroku. Kioku owns memory/session schema on Keiro. The application component is last when it owns
SQL. Keiki owns no schema. Shibuya is runtime/adaptor-only in the baseline.

The application component and plan preserve these architectural shapes:

```haskell
applicationMigrations :: Either DefinitionError MigrationComponent
applicationPlan :: Either DefinitionError (Either PlanError MigrationPlan)
```

Read actual exports before naming imports. The baseline search anchors are `pgmqMigrations`,
`kirokuMigrations`, `keiroMigrations`, and `kiokuMigrations`. Render the plan to derive counts; never
copy counts from examples.

Mount the selected standard CLI with explicit `plan`, `list`, `check`, `status`, `verify`, `up`,
`repair`, and `new` behavior as appropriate. A bare invocation must be a usage error, never `up`.
Construct and validate the plan before connecting to PostgreSQL.

Test manifests and pure plan construction, fresh apply, strict verification, a second zero-work
apply, live schema/data contracts, and the application data-access path. `verify` compares the plan
with the target ledger; add explicit live assertions because it is not a schema diff.

For Kiroku predecessor history, first inspect
`Kiroku.Store.Migrations.History.Codd`: the selected Kiroku release already exports the canonical
legacy filename mappings, manifest text, source config/payload helpers, and legacy names. Prefer
that prebuilt mapping over duplicating it in the application. For a persistent database with the
known cohort transition, use the `cohort-migrate` skill as the automated discovery, composition,
and restored-clone proof path when available; retain the manual runbook as the auditable fallback.

## Phase 5: Adopt the vertical module structure

This phase is code motion only. Preserve externally observable behavior and prove the target's
existing test suite passes immediately before and after it.

The target is the six-package service layout with concept-first vertical slices: each aggregate has
a disposable `Generated.{Domain,Codec,EventStream,Projection,Harness}` ring and a hand-owned
`Holes` module, with its API, handler, worker, and read model under the same concept namespace.
Cross-cutting prelude, application config, PostgreSQL runners, migration plan, worker registry, and
server boot modules retain technical names.

If the service is Keiro-DSL-generated, update the spec to `layout collocated`, use the matching
released Keiro DSL 0.3 tool, and re-scaffold so deterministic module moves fall out of the spec.
Never hand-edit a module marked `-- @generated`. If the service is hand-rolled, move one concept at
a time, update Cabal `exposed-modules` and imports, compile, and run that concept's tests before the
next move. Read `vertical-structure-refactor.md` and the
`architecture-vertical-slice-modules`, `architecture-service-packages`,
`architecture-spec-and-scaffolding`, and `architecture-test-layout` DocRefs in
`shinzui/keiro-runtime-patterns` for the full target and test layout.

## Phase 6: Migrate configuration to Settei

This phase changes the loading mechanism, not the values the service resolves. Inventory every raw
Dhall `FromDhall`, environment read, CLI override, default, secret, and operational config key.
Capture a redacted resolved-config fixture before editing. Declare the same keys and defaults as an
inspectable Settei `Config`, keep sensitivity on each `Setting`, and resolve explicit general files,
mounted Secret directories, then explicit environment bindings. Use `RejectUnknownKeys` and never
log the resolved record or secret values.

Expose Settei's describe/explain modes and `--check-config` using reserved exit codes 2, 3, and 4.
The check path must load exactly the normal sources and exit before opening listeners or starting
workers. Diff the redacted before/after configuration and run existing configuration tests before
changing deployment manifests. Then gate Kubernetes startup with the same image, arguments,
environment, and mounts. Read `settei-migration.md`, `config/settei-service-standard`, and
`config-kubernetes-deployment` in `shinzui/keiro-runtime-patterns` for the exact APIs and rollout
sequence.

## Phase 7: Classify database state and apply the selected policy

Classify from read-only evidence as one of:

- build-only/no database;
- fresh or proven disposable;
- exact supported predecessor history;
- partial predecessor history;
- mixed native/imported and predecessor history;
- unsupported or ambiguous.

Apply `Database policy: {{database.policy}}` exactly:

- `ask`: classify first. Ask one focused question only when evidence cannot determine whether data
  may be erased or must be preserved. Do not ask merely because the workflow is long.
- `preserve`: forbid writes to a data-bearing database until there is a reviewed migration/cutover
  plan, verified pre-write backup, writer quiescence procedure, and successful restored-clone
  rehearsal with the intended artifact.
- `disposable`: still prove that the exact URL is local, unshared, non-production, and safe to
  erase. Ask for explicit destructive confirmation immediately before the target lifecycle resets
  it. The selected policy is not itself destructive authorization.

If evidence contradicts the selected policy, stop and report the contradiction. Do not silently
switch paths or write.

### Build-only/no database

Finish dependency alignment, runtime adaptation, manifest/component authoring, pure plan tests, and
database-free `plan`/`list`/`check` rendering. Do not claim database acceptance. Hand off the exact
inventory, backup/classification, apply, verify, no-op, live-assertion, and smoke steps an operator
still must run.

### Disposable fast path

Stop and switch to preservation if the target is remote, shared, production-like, contains data to
retain, has a non-empty target ledger of unclear provenance, has unknown predecessor rows, or has
any ownership uncertainty.

Complete build/runtime/plan work before destruction. Then show a sanitized target identity, why it
is local/unshared/non-production, what will be lost, and the target project's documented reset and
recreate operation. Ask for explicit confirmation immediately before running it. Do not prescribe a
generic `dropdb`; use the target's lifecycle and present destructive commands for approval.

After confirmation:

1. recreate the exact confirmed database;
2. render the production plan and confirm `pgmq -> kiroku -> keiro -> kioku -> application`;
3. run the complete `up` once;
4. run strict `verify`;
5. run live schema and data assertions;
6. reconcile Kioku's read-model registry when present;
7. run the complete `up` again and prove zero new work;
8. run a representative application read/write and worker/queue smoke;
9. only then remove obsolete Codd/hasql/legacy runners and bootstrap writers;
10. rebuild and rerun the target checks.

If apply fails, preserve evidence and recreate the confirmed disposable database before retrying a
changed plan. Never patch ledger rows.

### Persistent-data path

Do not initialize the target ledger during inventory. Classify each component separately:

- exact legacy: complete supported source prefix, no target rows—import before native apply;
- partial legacy: incomplete source prefix—stop and remediate truthfully;
- mixed: preserve truthful native/imported prefixes and import only untouched complete components
  with a checked component-aware profile;
- ambiguous/unsupported: stop and design a reviewed remediation plus read-only validators.

Take a verifiable pre-write backup, record its checksum and restore command, and quiesce every
application, worker, scheduler, Codd process, hasql-migration process, bootstrapper, and other writer.
Restore the backup into an isolated clone and prove its ledger, schema, row-count, extension, and
business-invariant baseline. Run the entire cutover on this restored clone with the production
artifact. A failed rehearsal restarts from a fresh restoration, not a manually repaired clone.

History import records evidence without executing mapped SQL. For every component:

- mappings form a gap-free prefix beginning at position 1;
- `SamePayload` requires preserved exact source bytes matching the target manifest;
- `EquivalentState` requires explicit opt-in and a domain-specific read-only validator;
- selected and unselected source rows are reviewed and preserved in audit output;
- import occurs before any native target row for that component;
- identical re-import may be idempotent, but changed evidence is a conflict.

Use the pg-migrate Codd adapter for its documented shapes and source-lock behavior. Codd has no
historical payload checksum, so exact bytes plus a checked manifest and confirmation are needed for
same-payload evidence. Quiesce Codd writers because they may not honor the cooperating lock.

Use the hasql-migration adapter with a validated qualified source table, not `search_path`. It
recomputes the predecessor MD5 from exact bytes and separately proves the target SHA-256 relation.

PGMQ may share `public.schema_migrations` with unrelated rows. In PGMQ `0.4.0.1`, use its explicit
lenient source-ledger policy (`AllowUnselectedSourceRows` in that release), display and review
`unselectedRows`, and keep selected checksum/state validation strict. Never delete unrelated rows.

Apply only checked-in, idempotent, profile-bound schema/filename remediation. Examples include
Keiro schema relocation and Kioku registry reconciliation, but derive the exact objects and checks
from the target. Calculate exact pending-ID and ledger-total oracles from selected manifests and
source mappings—not example counts.

On the restored clone, prove in order:

```text
read-only identity/preflight
source-adapter check-only reports
reviewed remediation when required
history imports and exact intermediate oracles
full up and exact pending-ID oracle
strict verify and final ledger oracle
live schema/data/business assertions
Kioku read-model reconciliation when present
second full up with zero new work
representative application and worker smoke
```

Only after clone proof may the operator schedule a real cutover. Repeat the exact procedure after a
new backup and verified writer quiescence. Record artifact/cohort/database identities and all audit
output. Restore the pre-write backup on failed cutover; never edit target ledger rows. Retain the
backup and predecessor machinery through application/worker smoke and the agreed production soak.
Remove legacy engines only after soak.

## Phase 8: Validation and handoff

Run the target's formatter, complete Cabal build/test path, active Nix build/check path when present,
manifest checks, pure plan tests, and Git whitespace/status review. For the selected database path,
retain concise evidence for classification, operator approvals, component order and
manifest-derived counts, history mappings, backup/restore, apply, strict verify, no-op reapply, live
assertions, Kioku reconciliation, and the application smoke.

Also retain the before/after test result for the vertical code-motion phase, the final six-package
module inventory, the redacted resolved-configuration diff, Settei binding/configuration tests, and
the `--check-config` result. A handoff is incomplete if either structural or configuration behavior
drift is unexplained.

Re-run read-only status and strict verification after any prompt-driven fix that changes migration
code. If the repository uses an ExecPlan or ADR process, update those living documents with
progress, discoveries, decisions, validation output, and durable operational context.

Finish with a handoff that clearly distinguishes:

- completed code and database work;
- exact validations and observed results;
- preserved backups/audit evidence and rollback point;
- remaining environment-specific cutovers or soak/cleanup work;
- any blocker that stopped the workflow before writes.

Offer to create a Conventional Commit only when the target's applicable gates pass. Follow its
commit trailers and other local rules. Do not push.
