# Disposable database fast path

Use this path only for a database the operator has affirmatively classified as local, unshared,
non-production, and safe to erase. A small or young project is not automatically disposable. The
decision depends on the database and its data ownership, not repository age or migration count.

This path removes history-import and production-soak work. It does not weaken source discovery,
plan construction, destructive confirmation, strict verification, live-schema assertions, or the
application smoke test.

## Establish the classification with read-only evidence

Read repository instructions and locate dependency APIs with Mori. Inventory:

- every configured database URL and its environment or role;
- whether the database is local, shared by another service, or reached by a production/staging job;
- every current migration engine, migration directory, ledger, and schema writer;
- whether any data, audit record, queue, or manual fixture must survive;
- backup/restore and database lifecycle commands documented by the target;
- the complete future pg-migrate component plan.

Run only read-only inspection during classification. Render `plan` and `list`, inspect existing
Codd/hasql-migration/pg-migrate ledgers, and query catalog/table counts with a read-only role when
available. `status` and `verify` are read-only in pg-migrate; a missing target ledger should remain
missing until the approved apply.

Sanitize connection strings in notes and logs. Record the database name, host class, role, and the
evidence for “local,” “unshared,” and “non-production” without printing credentials.

## Stop conditions

Do not use this fast path if any of the following is true:

- the connection is remote, production, staging with meaningful state, or otherwise not proven
  local;
- another service, developer, test suite, or migration process shares the database;
- the operator cannot affirm that all rows and objects may be erased;
- a non-empty `pgmigrate` target ledger exists and its provenance is not fully understood;
- Codd, hasql-migration, PGMQ, or another predecessor ledger contains unknown or unexpected rows;
- a queue, audit trail, manually curated fixture, or user record must be retained;
- the selected policy says `preserve`, or evidence contradicts a requested `disposable` policy;
- any uncertainty remains about database identity or ownership.

When a stop condition appears, do not initialize the target ledger or run `up`. Reclassify as
persistent/ambiguous and use `persistent-database-cutover.md`.

## Finish code and plan work before destruction

Complete all database-free implementation before asking to erase anything:

1. Select one coherent cohort and make Cabal and Nix resolve it.
2. Adapt Kiroku, Keiro, Shibuya, PGMQ, and Kioku runtime APIs from selected source.
3. Preserve existing SQL evidence and author strict manifests/components.
4. Compose and render `pgmq -> kiroku -> keiro -> kioku -> application`.
5. Mount an explicit CLI whose bare invocation cannot mean `up`.
6. Compile, run unit tests, validate manifests, and inspect `plan` and `list` without database
   writes.
7. Remove implicit framework schema initialization from runtime startup, but do not remove the
   predecessor engine yet.

If the project owns no application SQL, record that the plan ends at Kioku. Derive counts from the
selected manifests and rendered plan, not from another service.

## Ask immediately before reset

Show the operator a concise, sanitized statement containing:

- the exact target environment and database identity;
- the evidence that it is local, unshared, and non-production;
- what data and objects will be lost;
- the target repository's lifecycle operation that will recreate it;
- the migration artifact and component order that will be applied afterward.

Ask for explicit destructive confirmation at this point, even when the blueprint policy is
`disposable`. Do not treat an earlier choice of policy as authorization for the reset. If the
operator declines, stop without changing the database.

Use the target project's documented database lifecycle rather than prescribing a generic
`dropdb`, container deletion, or cloud command. Present each destructive command for deliberate
interactive approval. Never connect a reset command to a database URL inferred from an unchecked
default.

## Recreate and prove the production plan

After confirmation, run the target's reset/recreate operation and then use the same migration
artifact intended for normal deployment. Do not use a test-only schema shortcut or old bootstrap
helper.

The proof sequence is:

```text
recreate confirmed target
render plan and expected component order
run full up
run strict verify
run live schema and data assertions
run full up again and observe zero newly applied migrations
run a representative application read/write smoke
```

Record the first apply report. Every declared entry should be applied in component order. Strict
`verify` must report no pending, unknown, checksum, position, kind, or transaction-mode issue. The
second `up` must report every entry already applied or otherwise prove zero work.

Ledger agreement is not a schema diff. Assert the actual schemas, tables, columns, indexes,
constraints, functions, extensions, and role access the service needs. If Kioku is present, run its
read-model registry reconciliation after successful migration. Then start the application in its
normal local mode, perform a representative write and read, and check workers or queue processing
when they are part of the service.

## Remove old machinery only after proof

After the fresh apply, verify, no-op reapply, live assertions, and smoke all pass:

- remove Codd/hasql-migration/legacy runner dependencies and commands that no longer own schema;
- remove runtime bootstrap schema creation now owned by pg-migrate;
- retain historical SQL or lock evidence when it explains deployed history or is still needed for
  persistent environments;
- rebuild and rerun tests through both Cabal and Nix.

Do not delete the predecessor engine before the new plan is proven. A local disposable success also
does not authorize migrating a persistent environment; that environment follows its own inventory,
backup, clone rehearsal, and cutover gates.

## Failure and retry

If the reset fails before recreation, use the target lifecycle to recreate the same confirmed local
database and retry. If `up` fails, preserve the error and ledger state long enough to understand the
failure. Because the database is confirmed disposable, recreate it again before retrying a changed
plan; do not patch ledger rows in place.

If evidence discovered during or after reset shows the database was not actually disposable, stop.
Do not continue writing, and do not claim rollback from ledger edits. Escalate to the operator and
recover from whatever pre-reset backup or external source of truth they identify.

## Acceptance record

The fast path is complete only when the handoff records:

- explicit destructive confirmation and the sanitized target identity;
- selected cohort and build artifact identity;
- rendered component order and manifest-derived counts;
- first `up`, strict `verify`, and second zero-work `up` results;
- live schema/data assertions and application smoke results;
- obsolete migration/bootstrap machinery removed only after proof;
- any work that remains for persistent environments.

This guidance synthesizes the pg-migrate deployment and testing runbooks at revision
`f39d64e354818999667d345a1452f33eb4857fc1` and the disposable-development lessons in Rei
master plan 19 and ExecPlans 157 and 165–171 recorded at revision
`d17fcad24bdbd69765849c07c692615c58450872`. The application names, database URLs, and literal
counts in those plans are intentionally not reproduced here.
