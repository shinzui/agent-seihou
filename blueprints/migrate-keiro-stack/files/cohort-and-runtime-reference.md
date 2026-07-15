# Cohort and runtime reference

This reference helps an agent select one mutually compatible release cohort for a Haskell service
that uses pg-migrate, PGMQ, Kiroku, Keiro, Kioku, and Shibuya. A **cohort** is a set of package
versions proven to build and operate together; it is not whatever version of each package happens
to be newest. The application must resolve the same cohort through both Cabal and Nix.

The commands and checks below are portable. Paths and package counts from a previous application
are evidence about that application only and must not be copied into a new migration.

## Discover dependencies before editing

Read the target repository's instructions and preserve its existing work. If `mori.dhall` exists,
start with the target's declared identity, then discover each dependency through Mori:

```bash
mori show --full
mori registry list
mori registry search pg-migrate
mori registry search pgmq
mori registry search kiroku
mori registry search keiro
mori registry search kioku
mori registry search shibuya
```

For every selected project, inspect its registered source path, packages, and documentation before
using an API. For example:

```bash
mori registry show shinzui/pg-migrate --full
mori registry docs shinzui/pg-migrate
mori registry show shinzui/keiro --full
mori registry docs shinzui/keiro
```

Repeat `registry show` and `registry docs` for Kiroku, Kioku, Shibuya, the Shibuya PGMQ adapter,
and pgmq-hs when Mori found them. Read the selected source and local documentation at the paths Mori
reported. Do not guess an import, effect row, constructor, or migration count from this reference.

If Mori has no registration, record the failed lookup. Use the target's Cabal files, lockfiles,
Nix inputs, and an explicitly located checkout or published source. Never search `/nix/store`, and
never use compiler errors as a substitute for locating the dependency source. Compiler errors are
useful only after the selected API has been read.

## Known-good released baseline

The following Hackage cohort was verified on 2026-07-14. Pin an `index-state` no earlier than
`2026-07-14T19:01:33Z`; that timestamp is the last upload needed to see all PGMQ `0.4.0.1`
packages. This is a reproducible fallback and migration checklist, not a permanent definition of
“latest.”

| Area | Packages | Version |
| --- | --- | --- |
| Migration engine | `pg-migrate`, `pg-migrate-cli`, `pg-migrate-embed`, and any required history-import adapters | `1.1.0.0` |
| PGMQ | `pgmq-core`, `pgmq-config`, `pgmq-effectful`, `pgmq-hasql`, `pgmq-migration` | `0.4.0.1` |
| Keiro | `keiro`, `keiro-core`, `keiro-migrations`, `keiro-pgmq` | `0.3.0.0` |
| Kiroku | `kiroku-store` | `0.3.0.1` |
| Kiroku migration and tooling | `kiroku-store-migrations`, `kiroku-cli`, `kiroku-metrics`, `kiroku-otel` | `0.3.0.0`, `0.2.0.0`, `0.1.0.1`, `0.2.0.1` respectively |
| Kiroku/Shibuya bridge | `shibuya-kiroku-adapter` | `0.4.0.0` |
| Kioku | `kioku-api`, `kioku-core`, `kioku-migrations` | `0.1.0.0` |
| Keiki | `keiki`, `keiki-codec-json` | `0.2.0.0` |
| Shibuya | `shibuya-core`, `shibuya-metrics` | `0.8.0.1` |
| Shibuya PGMQ bridge | `shibuya-pgmq-adapter` | `0.12.0.0` |
| Supporting runtime | `shikumi`, `shikumi-cache`, `shikumi-trace` | `0.3.0.0`, `0.1.2.0`, `0.2.0.0` respectively |
| PostgreSQL notifications | `hasql-notifications` | `0.2.5.0` |

Select a later cohort only after the complete package graph resolves and the selected sources prove
the migration, runtime, and history-import APIs still agree. Record the chosen index-state, exact
versions, source revisions, and why the set is coherent.

## Keep Cabal and Nix on one source graph

Inventory every dependency declaration before changing one:

```bash
rg -n 'index-state|source-repository-package|packages:|optional-packages:' cabal.project '*.cabal'
rg -n 'github:|git\+|rev =|sha256|source-repository-package|pg-migrate|pgmq|kiroku|keiro|kioku|shibuya' flake.nix nix
```

Adapt the globs to the target's actual files. Replace stale workstation paths and incoherent pins
with one source policy. It is valid to use released packages or reviewed source pins, but Cabal and
Nix must resolve the same code. Do not delete unrelated application pins merely to make the cohort
look uniform.

After editing, inspect both solvers and build the complete application graph. A successful build of
only the migration executable is insufficient when the runtime uses a different dependency closure.
Use the target's documented commands; common evidence is:

```bash
cabal build all
nix flake check
```

When one tool cannot resolve the selected cohort, stop and reconcile its sources rather than
allowing Cabal and Nix to build different APIs under the same package names.

## Migration owners and dependency order

Five owners may contribute schema work to the final application plan:

1. `pgmq` creates queue infrastructure.
2. `kiroku` creates the event-store schema.
3. `keiro` creates framework schema on top of Kiroku.
4. `kioku` creates memory/session schema on top of Keiro.
5. the application contributes its own component last when it owns SQL.

The observable plan order is therefore:

```text
pgmq -> kiroku -> keiro -> kioku -> application
```

Resolve `pgmqMigrations`, `kirokuMigrations`, `keiroMigrations`, and `kiokuMigrations` from
the selected releases. Do not infer counts from this reference or a prior service: inspect the
embedded manifests and render the target plan.

Keiki owns no PostgreSQL schema. Shibuya and its adapters are runtime dependencies and do not add
another migration component in this baseline. Helpers such as TypeID may remain outside the native
plan when their selected package exposes no component; record that boundary and make the database
preflight run before any remaining bootstrap writer.

## Compiler-guided runtime adaptation checklist

Search the target and the selected dependency sources for these anchors. Exact modules and types
come from the selected cohort.

### Kiroku ownership

`KirokuStoreResource` represents one process-scoped Kiroku store. Long-lived entry points should
acquire it once with the selected `withKirokuStore`/resource runner and interpret store operations
against that handle. Replace ad hoc `withStore` or `runStoreIO` ownership only after reading the
current Kiroku API. When explicit migrations own framework schema, configure runtime acquisition
not to initialize that schema implicitly.

### Keiro replay boundary

Keiro command runners, projections, routers, and process managers accept
`ValidatedEventStream`, not a raw `EventStream`. Generated aggregates should be regenerated with
the matching Keiro DSL. Hand-authored aggregates should construct a validated value at the wiring
boundary and handle validation failures there. Do not use unchecked construction to silence a
compiler error.

### Shibuya handler and application API

Current Shibuya applications call `runApp` with an `AppConfig`, commonly starting from
`defaultAppConfig`. Handler-facing values are `Message` records containing an envelope and an
optional lease; the framework retains the acknowledgement handle. Read the selected `Shibuya`
facade before adapting record patterns or handler signatures.

### Shibuya PGMQ adapter and Keiro PGMQ

The baseline constructs a `PgmqAdapterEnv` from the Hasql pool with `mkPgmqAdapterEnv`.
`pgmqAdapter` receives that environment and validated configuration and returns
`Either PgmqConfigError ...` inside its effect. Keiro PGMQ job processors therefore carry
`Reader PgmqAdapterEnv` in the relevant effect stack. Preserve the selected source's complete
`Pgmq`, tracing, error, and IO constraints rather than copying an older stack.

### Kioku read-model registry

Kioku read models are registered once during application runtime acquisition. A composed migration
host must also run the selected Kioku registry reconciliation after a successful migration and
before traffic resumes. In the baseline, `reconcileReadModelRegistry` is idempotent and must run at
migration time rather than racing on every application startup. Read-only `status` and `verify`
must not reconcile or mutate the registry.

## Proving the adapted cohort

Use compiler errors to find remaining call sites only after confirming the source API. Then run:

- pure construction tests for every component and the complete plan;
- target build and unit tests under Cabal;
- the corresponding Nix build/check path;
- a fresh-database apply with every component;
- strict ledger verification and a second `up` that applies zero migrations;
- live schema/data assertions and a representative application read/write smoke.

If the database is persistent, do not perform the database steps until the persistent cutover
preflight, backup, and restored-clone gates in `persistent-database-cutover.md` have passed.

## Source provenance

The baseline and checklist synthesize these sources:

- pg-migrate revision `f39d64e354818999667d345a1452f33eb4857fc1`, especially
  `docs/user/quickstart.md`, `manifest-authoring.md`, `component-authoring.md`,
  `plan-composition.md`, `cli-integration.md`, and `testing.md`, plus the operations runbooks;
- Keiro revision `29bd7952fa5201adf789bbb21427b2cffe228d4b`, especially
  `docs/user/migrations.md`, `migration-ownership.md`, `api-reference.md`,
  `command-cycle.md`, and `docs/guides/migrating-to-validated-event-stream.md`;
- Kioku revision `a99aa369701a76278ca33d83f8416dee443fa645`, especially
  `docs/user/upgrading-to-pg-migrate.md` and the read-model reconciliation API;
- Mori revision `d39cae1d8321ae5916152ac17cf3732ad0344f8b`, especially master plan 19 and
  ExecPlans 137–145 describing cohort resolution, the five-component plan, restored-clone
  rehearsal, history import, and cleanup;
- Rei field report revision `d17fcad24bdbd69765849c07c692615c58450872`, especially master plan 19,
  ExecPlan 157, and ExecPlans 165–171 describing disposable development, mixed-ledger
  classification, clone rehearsal, import, cutover, and delayed cleanup.

The canonical upstream repositories are `https://github.com/shinzui/pg-migrate`,
`https://github.com/shinzui/keiro`, and `https://github.com/shinzui/kioku`. Mori should locate
local source first. If these revisions are deliberately refreshed, record the replacement
revisions and revalidate every fact that depends on them.
