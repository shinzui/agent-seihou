# Vertical Structure Refactor

Use this guide to move an existing service into the fleet module structure without changing
behavior. Treat the refactor as code motion: run the existing test suite before the first move and
after every concept lands, and leave runtime, database, and wire semantics unchanged.

## Target the six-package ownership model

The service uses flat root packages named `<service>-core`, `-api`, `-migrations`, `-workers`,
`-server`, and `-client`. Read models live in core beside the domain concept they project; there is
no separate PostgreSQL package. The target module tree for one concept is:

```text
<service>-core/src/Namespace/Widget/
  Generated/Domain.hs
  Generated/Codec.hs
  Generated/EventStream.hs
  Generated/Projection.hs
  Generated/Harness.hs
  Holes.hs
  ReadModel.hs
<service>-api/src/Namespace/Widget/Api.hs
<service>-workers/src/Namespace/Widget/Worker.hs
<service>-server/src/Namespace/Widget/Handler.hs
```

Only cross-cutting infrastructure keeps a technical-layer name: `Namespace.Prelude`,
`App.Config`, `Postgres.{Pool,Runner}`, `Migrations`, `Workers.{Subscription,Registry}`, the API
umbrella, and `Server.{Config,App,Seam,Boot}`.

## Preserve the generated/hand-owned firewall

`Generated.*` is deterministic output and every generated module carries `-- @generated`. Change
the `.keiro` spec and regenerate; never patch generated Haskell. `Holes` is the hand-owned ring for
the Keiki decision transducer and read-model apply fold. The scaffolder creates it only when absent
and must never overwrite it. Concept API, handler, worker, and read-model modules are also
hand-owned.

The shipped `Generated.*` plus `Holes` convention is authoritative. Earlier flat-layout prose in a
Danwa Cabal description was an abandoned intermediate design; do not move generated code back into
flat concept modules to match it.

## Choose the move mechanism from evidence

For a Keiro-DSL service:

1. verify the target spec models current behavior;
2. add `layout collocated` after the context declaration;
3. install or run the selected released Keiro DSL 0.3 tool;
4. check the spec, scaffold into `<service>-core/src`, and format;
5. use the generated manifest to update Cabal `exposed-modules`;
6. review the diff for unexpected deletion or overwrite before compiling.

```bash
keiro-dsl check domain/<context>.keiro
keiro-dsl scaffold domain/<context>.keiro --out <service>-core/src
git diff --stat
```

For a hand-rolled service, move one concept at a time. Start with its domain/event stream and
hand-owned behavior, then its read model, API, handler, and worker. Update module declarations,
imports, `exposed-modules`, and tests in the same slice. Compile and run that concept's tests before
starting another. Do not combine code motion with schema, DTO, command, event, or error changes.

## Land on the fleet test layout

Preserve existing tests and make ownership explicit:

- core `test-domain` runs every generated `harnessAssertions`;
- core `test-diagrams` checks lifecycle diagram freshness;
- core `test-postgres` exercises read models against a migrated ephemeral database;
- migrations tests prove manifest/plan construction, apply, ledger/schema assertions, and no-op
  reapply;
- server tests exercise handlers against an ephemeral migrated database;
- workers tests mirror `src` with per-concept `*Spec` modules.

Run the repository's complete build and test commands before and after. A module path diff plus a
green equivalent test inventory is the behavior-preservation evidence. If a test has to change,
explain why it asserted layout rather than behavior; do not silently weaken it.

## Normative citations

Discover these docs with `mori registry docs shinzui/keiro-runtime-patterns`:

| Topic | Path | DocRef key |
|---|---|---|
| Package ownership | `architecture/service-packages.md` | `architecture-service-packages` |
| Vertical slices | `architecture/vertical-slice-modules.md` | `architecture-vertical-slice-modules` |
| Spec/scaffolding lifecycle | `architecture/spec-and-scaffolding.md` | `architecture-spec-and-scaffolding` |
| Test ownership | `architecture/test-layout.md` | `architecture-test-layout` |
| Extended nodes | `architecture/extended-node-verticals.md` | `architecture-extended-node-verticals` |
| DSL adoption | `keiro/dsl-adoption.md` | `keiro-dsl-adoption` |

Read the selected Keiro source through Mori before using a DSL command or generated type. The docs
define the fleet target; the target repository's tests define the behavior that must survive.
