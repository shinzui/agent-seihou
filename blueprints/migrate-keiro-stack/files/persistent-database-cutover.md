# Persistent database cutover

Use this path whenever data must survive, the database is shared or remote, predecessor history is
present, or disposability is uncertain. The workflow is fail-closed: classify and preserve evidence
before any command can initialize or mutate the pg-migrate target ledger.

A persistent cutover succeeds first on a restored clone, then repeats the reviewed artifact and
procedure during a controlled production window. Restoring the pre-write backup is rollback.
Deleting or rewriting pg-migrate ledger rows is not rollback.

## Phase 1: Read-only inventory before target-ledger initialization

Read target instructions, use Mori to locate selected dependencies, and record the exact cohort,
source revisions, migration artifact, Git identity, and dirty state. Sanitize database URLs while
recording the host, database, and role actually selected.

Inventory without writes:

- current Cabal and Nix dependency sources;
- every SQL directory, strict or informal manifest, and embedded payload;
- all Codd, hasql-migration, pg-migrate, package-specific, and application-owned runners;
- all legacy and target ledgers, including schemas, columns, row identities, checksums, status, and
  timestamps;
- all schema writers hidden in normal startup, tests, workers, queue setup, and helpers such as
  TypeID;
- runtime entry points and database URLs by operational role;
- table locations, row counts, critical business invariants, extensions, ownership, and grants;
- backup, restore, writer-quiescence, and smoke-test procedures.

Use read-only catalog queries or a read-only transaction. Render `plan`, `list`, `status`, and
`verify` only when the selected executable's implementation confirms they cannot write. Do not run
`up`, `repair`, a mutating history import, runtime startup, or any helper that creates a ledger or
schema during inventory.

Preserve predecessor SQL bytes and filenames before moving or formatting them. For each history
source, identify the exact selected rows, unselected rows, source table/schema, payload source,
checksum algorithm, and potential state validator.

## Phase 2: Classify the starting state

Classify each migration owner and the complete database into one of these states:

1. **Build-only/no database.** The code can compile and render a plan, but no database proof is
   available. Stop after database-free validation and list the operator work still required.
2. **Fresh.** No selected predecessor rows, target component rows, or owned live schema exists.
   A reviewed fresh apply is allowed only after backup/clone policy for the environment is settled.
3. **Exact predecessor history.** A complete supported legacy prefix exists and no target row for
   that component exists. Import the proven prefix before native application.
4. **Partial predecessor history.** A supported prefix is incomplete or a selected row is missing.
   Stop. Complete or remediate the predecessor state with reviewed, source-specific tooling; do not
   pretend the missing work happened.
5. **Mixed native/imported history.** One or more truthful pg-migrate prefixes coexist with untouched
   legacy components. Preserve native rows and use a component-aware recovery/import profile for
   only the untouched complete components.
6. **Unsupported or ambiguous.** Evidence does not match a checked-in profile, two source schemas
   conflict, bytes are missing, the database identity is unclear, or live state contradicts the
   ledgers. Stop and design a reviewed remediation and read-only validator.

Classification is per component before it is summarized for the database. Do not assume an empty
pg-migrate ledger means the live schema is fresh. Do not assume a non-empty Codd or
`public.schema_migrations` table belongs entirely to the framework or application.

If evidence contradicts a selected `preserve`/`disposable` policy, report the contradiction and
stop before writes.

## Phase 3: Back up, quiesce, restore, and rehearse

Take a pre-write backup with the target's documented method. For PostgreSQL, a custom-format
`pg_dump` is often appropriate, but use the service's operational policy and privileged role. Record
the backup path or object identifier, checksum, server/database identity, tool version, start/end
time, and restore command. List or inspect the backup to prove it is readable.

Stop every application, worker, scheduler, migrator, and bootstrap process that can write. The
pg-migrate target advisory lock serializes cooperating target operations; old Codd and
hasql-migration processes may not honor it. Writer quiescence is therefore an operator gate, not an
implementation detail.

Restore the backup into an isolated clone with separate credentials and no production network
consumers. Prove the clone matches the source inventory: predecessor ledger rows, pg-migrate rows,
owned table counts, critical data invariants, extensions, and schema locations. Reject any command
whose displayed identity is not the clone.

Run the entire cutover on this clone with the exact artifact intended for production. Preserve
machine-readable output, intermediate ledger counts derived from the selected mappings/manifests,
and assertion results. If a step fails, retain evidence, discard the changed clone, restore a fresh
clone, and retry the changed reviewed procedure from the beginning.

## Phase 4: Build the ordered native plan

Resolve library components from selected source and compose:

```text
pgmq -> kiroku -> keiro -> kioku -> application
```

The application component is present only when the target owns SQL. Keiki and Shibuya are runtime
dependencies in the baseline, not migration owners. Preserve any remaining helper outside the plan
only when no native component exists, and run database preflight before that helper writes.

Every owner embeds a strict append-only manifest. The module containing `embedMigrationManifest`
uses `Database.PostgreSQL.Migrate.Embed.RecompilePlugin` on GHC 9.12. Mount an explicit
administrative CLI; a bare invocation must not mean `up`. Derive counts and exact pending IDs from
the selected manifests and source ledgers, never from Mori, Rei, Kioku, or an example in this file.

Disable framework schema initialization during normal runtime after the explicit plan takes
ownership. Keep old migration engines available until the clone and production proofs complete.

## Phase 5: Import exact predecessor history

History import writes target ledger and append-only audit facts without executing mapped target SQL.
Perform it before applying any native row from the affected component.

For each source-to-target mapping:

- require a known target `MigrationId` and a gap-free component prefix starting at position 1;
- use `SamePayload` only when preserved exact source bytes prove the target payload checksum;
- use `EquivalentState` only with explicit operator opt-in and a domain-specific read-only
  `StateValidator` that proves the live result required by the target;
- retain selected and unselected source rows in the preflight report;
- require a non-empty audit reason and all source-specific confirmations;
- run under the target advisory lock and the source adapter's documented lock;
- preserve the complete audit report.

An identical import may report already imported. Changed source evidence, reason, resolved target
metadata, or audit JSON is a conflict and must never update the first fact.

### Codd sources

Use the pg-migrate Codd adapter for only its documented V1–V5 shapes. Codd records filenames and
status but no historical SQL checksum. Same-payload import therefore needs the checked-in payload
bytes, a verified lowercase SHA-256 manifest, and explicit confirmation. Without exact bytes, use a
reviewed `EquivalentState` validator or stop. Strict source selection is appropriate only when the
selected rows should be the entire Codd ledger; otherwise report and preserve unrelated rows.

Quiesce every Codd process. Its processes may not honor the adapter's cooperating source lock.

### hasql-migration sources

Use a validated schema-qualified source table, commonly `public.schema_migrations`; do not rely on
`search_path`. The adapter should reproduce the predecessor base64 MD5 from exact payload bytes and
then compare SHA-256 with the target for `SamePayload`. Names and MD5 alone do not prove
`EquivalentState`; that path still requires a read-only validator and explicit opt-in.

### PGMQ shared source ledger

PGMQ predecessor rows may coexist with application rows in `public.schema_migrations`. The PGMQ
`0.4.0.1` adapter exposes an explicit shared-ledger source policy, named
`AllowUnselectedSourceRows` in that release. Inspect and display `unselectedRows` before import.
The policy relaxes only source exclusivity: selected PGMQ rows must remain unique and checksum-valid,
and alternative two-step history still requires its PGMQ state validator and explicit equivalent
history opt-in. Neither reading nor importing may edit unrelated predecessor rows.

Never replace a source-specific shared-ledger policy with manual row deletion.

## Phase 6: Remediate supported live-state differences

Some exact predecessor profiles require state remediation before import, such as moving Keiro
framework tables into the `keiro` schema or reconciling a documented filename sentinel. Use only a
checked-in, idempotent, reviewed script bound to the selected profile. Run it first on the restored
clone and assert its preconditions and postconditions.

When history is equivalent rather than byte-identical, the read-only validator must cover the live
objects and invariants on which the application depends. Examples include schema-qualified table
locations, columns, primary/foreign keys, indexes, workflow backfills, and PGMQ catalog contracts.
Do not generalize another service's table list.

After the native plan succeeds, reconcile Kioku's compiled read-model registry once at migration
time. In the 2026-07-14 cohort, `reconcileReadModelRegistry` is idempotent and derives identities
from the same `ReadModel` values queries use. Read-only commands do not perform this mutation.

## Phase 7: Apply, verify, and prove the clone

Before `up`, calculate exact oracles from the selected plan and mappings:

- target rows already present and truthful;
- rows imported per component;
- exact pending native migration IDs;
- expected target ledger totals after import and after `up`;
- predecessor unselected rows that must remain unchanged.

Then run, in order:

```text
read-only preflight and identity check
source-adapter check-only/preflight
reviewed remediation, when required
mutating history imports
status and exact intermediate-oracle assertions
full up
strict verify
status and final-oracle assertions
live schema and data assertions
Kioku read-model registry reconciliation, when present
full up again with zero newly applied work
representative application and worker smoke
```

Strict `verify` proves plan/ledger agreement, not live-schema equality. Assert schema contracts,
row counts, business invariants, queue behavior, and representative reads/writes independently.
Confirm every imported historical entry was not executed and every expected native append ran once.
The second `up` must apply zero work.

Any unexpected native row, missing import audit, unknown target row, altered checksum, non-prefix
history, count mismatch, or live invariant failure stops the rehearsal. Do not repair the evidence by
editing `pgmigrate.migrations`.

## Phase 8: Production cutover and soak

Schedule a maintenance window only after a fresh clone rehearsal passes with the exact production
artifact and procedure. At cutover:

1. record artifact, Git, cohort, database, and role identities;
2. stop and verify all writers are quiescent;
3. take and verify a new pre-write backup;
4. repeat the clone-proven preflight, remediation, import, exact-oracle, `up`, verify,
   reconciliation, no-op, and smoke sequence;
5. restart traffic gradually and monitor errors, queue processing, database load, and critical
   read/write behavior;
6. retain backup and all audit output through the agreed soak period.

If a mutating step fails or an invariant is not met, stop writers and restore the pre-write backup
according to the practiced recovery procedure. After restore, re-inventory; do not continue from a
partially changed database by deleting target rows.

Only after successful production soak may the project remove Codd, hasql-migration, legacy runners,
old bootstrap writers, and transition-only code. Preserve historical evidence and ADR/runbook
context required to explain the durable ledger.

## Source provenance

This runbook synthesizes pg-migrate revision
`f39d64e354818999667d345a1452f33eb4857fc1`, especially the history-import, Codd,
hasql-migration, deployment, locking, and repair runbooks; Keiro revision
`29bd7952fa5201adf789bbb21427b2cffe228d4b`; and Kioku revision
`a99aa369701a76278ca33d83f8416dee443fa645`, whose upgrading guide is one exact profile
rather than a reusable count oracle.

Field-tested sequencing comes from Mori revision `d39cae1d8321ae5916152ac17cf3732ad0344f8b`
(master plan 19 and ExecPlans 137–145) and Rei field report revision
`d17fcad24bdbd69765849c07c692615c58450872` (master plan 19, ExecPlan 157, and
ExecPlans 165–171). Their application names, URLs, literal ledger counts, and environment
variables are deliberately replaced here with discovery and exact-oracle instructions.
