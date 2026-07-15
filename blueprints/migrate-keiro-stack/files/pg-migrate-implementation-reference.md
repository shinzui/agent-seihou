# pg-migrate implementation reference

This guide describes how a Haskell application adopts pg-migrate after dependency discovery has
selected a coherent cohort. It is an application-authoring checklist, not a source of migration
counts or import names. Read the selected dependency source through Mori before choosing imports or
copying a type signature.

## Preserve source evidence before refactoring

Inventory every existing migration file, runner, ledger, bootstrap writer, and database role. For
each predecessor SQL file, record its relative path, filename, exact bytes, and checksum before
moving it. Do not format historical SQL while relocating it. A filename and payload that already
reached a database are durable evidence.

Locate all schema writers, including normal application startup, tests, worker bootstraps, Codd,
hasql-migration, package-specific `migrate` helpers, and remaining helpers such as TypeID. Decide
which owner is responsible for each object. Runtime startup must stop creating framework schema
once the explicit migration plan owns it.

## Author one strict application component

Keep the application's migration files beside a strict ordered manifest:

```text
migrations/application/
├── 0001-existing-baseline.sql
├── 0002-forward-change.sql
└── manifest
```

Manifest format v1 is a UTF-8 list containing exactly one top-level lowercase `.sql` filename per
line, in execution order. It has no comments or directives. The embedder rejects blank lines,
duplicates, missing files, unlisted sibling SQL files, absolute or nested paths, `..`, surrounding
whitespace, and a byte-order mark. Include the manifest and SQL files in Cabal source distributions.

Embed the manifest in the module that exports the application component. On GHC 9.12, keep the
recompile plugin in that exact module so adding an unlisted SQL sibling retriggers validation:

```haskell
{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -fplugin=Database.PostgreSQL.Migrate.Embed.RecompilePlugin #-}

module Application.Migrations (applicationMigrations) where

import Data.Set qualified as Set
import Database.PostgreSQL.Migrate
  ( DefinitionError
  , MigrationComponent
  , migrationComponentFromEmbeddedSql
  )
import Database.PostgreSQL.Migrate.Embed (embedMigrationManifest)

applicationMigrations :: Either DefinitionError MigrationComponent
applicationMigrations =
  migrationComponentFromEmbeddedSql
    "application"
    Set.empty
    $(embedMigrationManifest "migrations/application/manifest")
```

The target application may use a different stable component name and dependency set. Choose them
once from ownership and actual SQL prerequisites. Never rename a released component or migration,
reorder applied entries, edit applied bytes, or insert before an applied entry. Append corrections.

Transactional SQL is the default. A nontransactional file uses the exact leading
`-- pg-migrate: no-transaction` directive and contains exactly one statement. It requires a
reviewed repair procedure because a crash may leave database effects present while the ledger is
`Running` or `Failed`.

## Compose the complete plan explicitly

The application owns the final `MigrationPlan`. Resolve each library component from the selected
release, then provide the stable dependency order directly:

```haskell
import Data.List.NonEmpty (NonEmpty (..))
import Database.PostgreSQL.Migrate
  ( DefinitionError
  , MigrationPlan
  , PlanError
  , migrationPlan
  )

applicationPlan :: Either DefinitionError (Either PlanError MigrationPlan)
applicationPlan = do
  pgmq <- selectedPgmqMigrations
  kiroku <- selectedKirokuMigrations
  keiro <- selectedKeiroMigrations
  kioku <- selectedKiokuMigrations
  application <- applicationMigrations
  pure (migrationPlan (pgmq :| [kiroku, keiro, kioku, application]))
```

The placeholder names above express ownership, not guaranteed imports. Read the selected packages
for the actual exported values; the 2026-07-14 baseline uses `pgmqMigrations`,
`kirokuMigrations`, `keiroMigrations`, and `kiokuMigrations`. Keiro depends on Kiroku,
Kioku depends on Keiro, and application dependencies must match the objects its SQL consumes.

The required observable order is:

```text
pgmq -> kiroku -> keiro -> kioku -> application
```

If the application owns no SQL, omit its component and document that fact. Keiki and Shibuya do
not contribute migration components in the baseline. Derive every component count from the
selected embedded manifests and the rendered plan; never copy counts from Mori, Rei, Kioku, or
this reference.

Resolve `DefinitionError` and `PlanError` before acquiring a database connection. A definition
error means an embedded name, payload, manifest, or SQL mode is invalid. A plan error means the
component set or dependency order is invalid.

## Mount an explicit administrative CLI

Use the selected `pg-migrate-cli` facade to expose the standard commands as explicit subcommands:

- `plan` and `list` render the embedded plan without database writes;
- `check` validates a filesystem manifest;
- `status` reads and classifies ledger state;
- `verify` strictly compares the complete plan with the ledger;
- `up` advances the complete plan under the advisory lock;
- `repair` handles one inspected nontransactional ambiguity with a reason;
- `new` creates a migration file and appends the manifest atomically.

Do not interpret a bare invocation as `up`. The application owns connection configuration, output,
logging, and exit mapping. Avoid printing connection strings because they may contain credentials.
Keep `RejectUnknownMigrations` unless the target intentionally shares the pg-migrate target ledger
and has reviewed the consequences of `AllowUnknownMigrations`.

Use `plan`, `list`, and `check` during authoring. For a database, the normal sequence is:

```bash
application-migrate status --database-url "$DATABASE_URL"
application-migrate verify --database-url "$DATABASE_URL"
application-migrate up --database-url "$DATABASE_URL"
application-migrate verify --database-url "$DATABASE_URL"
application-migrate up --database-url "$DATABASE_URL"
```

The first `verify` normally reports pending work for a new artifact. The post-`up` verify must be
clean, and the second `up` must report no newly applied migrations. Use the target's executable and
configuration conventions instead of copying `application-migrate` literally.

## Understand what verification proves

`status` and `verify` compare the declared plan with `pgmigrate.migrations`. Strict verification
checks identities, per-component positions, checksums, kind, transaction mode, applied-prefix
integrity, pending rows, and unknown rows. It does not diff the live PostgreSQL schema and does not
prove a data transformation's meaning.

Every plan therefore needs application-specific assertions after apply. Check the tables, schemas,
columns, indexes, constraints, functions, extensions, ownership, and representative row counts or
business invariants that the application depends on. Exercise the real data-access path with a
representative read/write smoke. Kioku hosts must reconcile the selected read-model registry after
successful migration and before serving traffic.

## Test at three boundaries

First, test without PostgreSQL:

- compile every module containing `embedMigrationManifest`;
- run `check` for every manifest;
- evaluate `applicationMigrations` and the complete `applicationPlan` in pure tests;
- assert the rendered component order and dependencies.

Second, apply the production plan to an isolated fresh PostgreSQL database:

- assert the first run applies every expected manifest entry;
- run strict `verify`;
- apply the same artifact again and assert zero new work;
- query live schema contracts for every owner.

Third, exercise the application against the migrated schema. For migrations that transform
existing data, add an old-plan-to-new-plan test with representative old rows. A fresh empty database
cannot prove a data migration.

Use the target's supported PostgreSQL major-version matrix. Keep ephemeral PostgreSQL helpers in the
test dependency closure, not production.

## Import predecessor history before native application

History import records a proven legacy prefix without executing target actions. For every affected
component, import before applying any native row from that component. A later attempt to relabel a
natively applied row correctly conflicts because it lacks source evidence.

Use `SamePayload` only when preserved source bytes exactly match the target payload. Use
`EquivalentState` only with explicit operator opt-in and a domain-specific read-only state
validator. Mappings must form a gap-free prefix starting at position 1. Retain the import audit
report. An identical import is idempotent; changed evidence is a conflict, not an update.

The Codd adapter supports its documented exact ledger shapes and requires quiescence because legacy
Codd processes do not necessarily honor the cooperating source lock. Codd stores no historical SQL
checksum, so same-payload claims also require preserved bytes, a checked manifest, and explicit
confirmation.

The hasql-migration adapter reads a validated qualified source table, normally
`public.schema_migrations`, reproduces the predecessor MD5 from exact bytes, and separately proves
the target SHA-256 relation. Alternative history still requires a read-only state validator.

PGMQ may share `public.schema_migrations` with unrelated rows. In the baseline, the PGMQ adapter's
explicit `AllowUnselectedSourceRows` source policy reports and preserves unselected rows while still
verifying selected PGMQ evidence. Do not replace this with a generic “ignore unknown rows” switch.

See `persistent-database-cutover.md` before any import into a data-bearing database.

## Recovery rules

pg-migrate is forward-only. Once a native or imported row is recorded, treat it as an audit fact.
Never delete, update, relabel, or manually backfill `pgmigrate.migrations`; never bypass a checksum
mismatch. Correct pending code before apply, append a new reviewed migration after apply, or restore
the pre-write backup and repeat the reviewed cutover on a fresh restoration.

For a nontransactional `Running` or `Failed` row, inspect live effects and logs first. Only then use
the standard repair command with an audit reason to mark a fully present effect applied or retry an
action proven safe. Finish with strict verification and preserve the repair report.

## Primary sources

This reference is based on pg-migrate revision
`f39d64e354818999667d345a1452f33eb4857fc1`: `docs/user/quickstart.md`,
`manifest-authoring.md`, `component-authoring.md`, `plan-composition.md`,
`cli-integration.md`, and `testing.md`; plus `docs/operations/history-import.md`,
`codd-import.md`, `hasql-migration-import.md`, `deployment.md`,
`locking-and-timeouts.md`, and `nontransactional-repair.md`.

The component ordering and runtime boundary are cross-checked against Keiro revision
`29bd7952fa5201adf789bbb21427b2cffe228d4b`, Kioku revision
`a99aa369701a76278ca33d83f8416dee443fa645`, and PGMQ `0.4.0.1`'s
`docs/user/schema-migration.md`. Locate all of them with Mori and read the selected release before
using exact imports.
