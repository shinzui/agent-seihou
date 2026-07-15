---
id: 1
slug: add-an-adaptive-pg-migrate-keiro-stack-blueprint
title: "Add an adaptive pg-migrate Keiro stack blueprint"
kind: exec-plan
created_at: 2026-07-15T03:03:42Z
intention: intention_01kxkv7rx0ettt9q270jh1kby1
---

# Add an adaptive pg-migrate Keiro stack blueprint

This ExecPlan is a living document. The sections Progress, Surprises & Discoveries,
Decision Log, and Outcomes & Retrospective must be kept up to date as work proceeds.
If durable project context changes, update or create ADRs in docs/adr/ in the same change.


## Purpose / Big Picture

Add a Seihou blueprint named `migrate-keiro-stack` that can inspect a Haskell/PostgreSQL
project and carry out the appropriate migration to the released pg-migrate, Kiroku, Keiro,
Kioku, Shibuya, and PGMQ cohort. The blueprint must be useful for both ends of the risk
spectrum: a small, non-production project can choose a short reset-and-rebuild path, while a
project with persistent data is routed through classification, backup, clone rehearsal,
history import, verification, and cutover gates. It must never infer that a database is
disposable merely because the project is young.

After this change, an operator can run `seihou agent run migrate-keiro-stack` in a target
repository, optionally set `database.policy` to `disposable` or `preserve`, and receive an
agent workflow grounded in portable reference files rather than Mori- or Rei-specific tribal
knowledge. The blueprint is visibly complete when Seihou validates it, both policy variants
render with their four bundled references, the registry advertises version `0.1.0`, and the
generated agent instructions contain the ordered `pgmq -> kiroku -> keiro -> kioku ->
application` plan plus the correct safety behavior for each database class.


## Progress

- [x] (2026-07-15T21:36:01Z) Read the full ExecPlan and PLANS.md, recorded the clean
  worktree baseline, resolved the repository identity with `mori show --full`, and discovered
  the registered pg-migrate/Keiro/Kiroku/Kioku/Shibuya/PGMQ sources and documentation.
- [x] (2026-07-15T21:42:36Z) Milestone 1: Authored and validated the four-file portable
  reference corpus. The files synthesize the recorded upstream and field-tested sources without
  operational dependence on author-machine paths, and `git diff --check` passes.
- [x] (2026-07-15T21:46:46Z) Milestone 2 implementation: Defined the adaptive blueprint and its
  operationally self-sufficient prompt. `seihou validate-blueprint
  blueprints/migrate-keiro-stack --lint` passes with one variable, no base modules, four reference
  files, and no declared tools.
- [x] (2026-07-15T21:52:31Z) Milestone 2 render proof: Rendered `ask`, `disposable`, and
  `preserve` from a temporary v0.4 registry copy. All three substitute the selected policy, list
  four readable references, retain the inline cohort/order/runtime guidance and both safety
  branches, and contain no author-machine path in `## Your Task`. The invalid-policy probe exposed
  v0.4's permissive unknown-pattern behavior; the prompt now rejects any non-enumerated value before
  its first repository inspection or tool call.
- [x] (2026-07-15T21:53:38Z) Milestone 3: Published the `migrate-keiro-stack` registry entry,
  generated its README with the blueprint README skill, updated the root catalog and usage examples,
  and reconciled pre-existing `exec-plan`/`master-plan` registry drift from `0.5.0` to `0.6.0`.
  Blueprint lint, registry sync check, registry validation, and `git diff --check` all pass.
- [ ] Milestone 4: Prove all policy renders and scenarios, run final validation, distill durable
  context, and complete the retrospective.


## Surprises & Discoveries

Document unexpected behaviors, bugs, optimizations, or insights discovered during
implementation. Provide concise evidence.

- Discovery: The Mori registry is no longer sparse for this cohort. All seven primary dependency
  projects resolved on 2026-07-15: `shinzui/pg-migrate`, `shinzui/keiro`, `shinzui/kiroku`,
  `shinzui/kioku`, `shinzui/shibuya`, `shinzui/shibuya-pgmq-adapter`, and
  `shinzui/pgmq-hs`.
  Evidence: `mori registry search` found each project, and `mori registry show <project> --full`
  returned its local source path, package list, and documentation metadata. The blueprint still
  needs the absent-registration fallback because it must work against other registries and future
  dependencies.

- Discovery: The planned pg-migrate, Keiro, Kioku, and Mori provenance revisions still match the
  registered checkout HEADs; the Rei checkout has advanced beyond the recorded field-report
  revision.
  Evidence: `git rev-parse HEAD` returned pg-migrate
  `f39d64e354818999667d345a1452f33eb4857fc1`, Keiro
  `29bd7952fa5201adf789bbb21427b2cffe228d4b`, Kioku
  `a99aa369701a76278ca33d83f8416dee443fa645`, Mori
  `d39cae1d8321ae5916152ac17cf3732ad0344f8b`, and Rei
  `edee58368afc3e5589d045f87ac9ec30d36943e1`.

- Discovery: The installed Seihou CLI has advanced from the plan-authoring toolchain to
  `v0.4.0.0 (2aa69ce)` and changes two blueprint-runtime facts.
  Evidence: `seihou --version` reports v0.4.0.0. Current source passes a readable blueprint
  `files/` directory through `--add-dir`, renders its location, and merges declared
  `allowedTools` with the setup allow-list. Debug runs also record a successful applied-blueprint
  entry in `.seihou/manifest.json`, so render proofs must run in a disposable temporary registry
  copy rather than this worktree.

- Discovery: Seihou v0.4.0.0 no longer enforces the blueprint's arbitrary validation expression.
  Evidence: `--var database.policy=production` exited 0 and rendered `Database policy:
  production`. The Mori-located v0.4 source in `Seihou.Core.Variable.simplePatternMatch` recognizes
  only the literal `[a-z][a-z0-9-]*` pattern and returns `True` for every other pattern, including
  `(ask|disposable|preserve)`. This is an upstream limitation, not a Dhall-definition error.


## Decision Log

- Decision: Build a direct project-migration blueprint, not a blueprint that merely generates
  another skill or document.
  Rationale: The requested outcome is a Seihou agent that knows how to migrate the repository in
  which it runs. It may create or maintain an ExecPlan when the persistent-data path needs staged
  work, but its primary contract is to inspect, edit, validate, and hand off the target project.
  Date: 2026-07-14

- Decision: Expose one `database.policy` variable with values `ask`, `disposable`, or `preserve`,
  defaulting to `ask`.
  Rationale: Database state changes the safe workflow more than project size does. The default
  lets the agent classify from evidence and ask only when ambiguity remains; the explicit values
  make automated or already-decided runs predictable. Even `disposable` still requires explicit
  confirmation immediately before a destructive reset.
  Date: 2026-07-14

- Decision: Bundle curated, portable references instead of pointing the running agent at absolute
  Mori, Rei, Keiro, Kioku, or pg-migrate checkout paths.
  Rationale: Sibling checkout paths are workstation-specific and may disappear. The references
  preserve source provenance and Mori discovery commands while carrying the operational facts
  needed to run offline. See the corrected decision below on how the running agent actually
  receives content, which changes what may live only in `files/`.
  Date: 2026-07-14

- Decision: Make `prompt.md` operationally self-sufficient; treat the four `files/` references as
  supplementary provenance, not as the agent's only source of the safe workflow.
  Rationale: This corrects an assumption baked into the first draft. Verified against the Seihou
  v0.3.0.0 (411b302) source, a blueprint's `files/` directory is **not** delivered to the running
  agent. `seihou agent run` renders a system prompt whose "## Reference Files" block lists only each
  file's basename and description (`Seihou.CLI.AgentLaunch.formatReferenceFiles`) and never inlines
  contents; the template then instructs the agent that when a reference "is not shown in this prompt"
  it must "ask the user to provide it rather than claiming to have read it". The `--add-dir` list
  passed to the provider comes from `Baikai.Kit.Session.agentDirsForSession`, which returns only
  `~/.config/<tool>/agents` and `<cwd>/.<tool>/agents` — never the blueprint's `files/` path. So in a
  target repository the four reference files are effectively unreadable unless the operator manually
  supplies them. Because this workflow can drop and recreate databases, an agent silently proceeding
  without its references is a safety hazard. Therefore every fact required to choose and execute the
  safe path — the known-good cohort table, the ordered `pgmq -> kiroku -> keiro -> kioku ->
  application` plan, both database branches, the fail-closed stop conditions, the Mori-first
  discovery rule, and the forbidden actions — must live inline in `prompt.md`. The `files/`
  references remain as deeper appendices; the prompt must tell the agent to read them only if they
  are actually reachable and to ask the operator to paste them otherwise, and must forbid fabricating
  their content.
  Date: 2026-07-14

- Decision: Require a tool-capable interactive provider (`--provider claude-cli`, the default, or
  `codex-cli`) and rely on interactive per-tool approval rather than the blueprint `allowedTools`
  field.
  Rationale: Verified against source, `seihou agent run` rejects the `anthropic` and `openai` API
  providers for interactive sessions (`Seihou.CLI.AgentLaunchExec.unsupportedInteractiveProvider`
  exits nonzero), and the runner ignores a blueprint's `allowedTools`, always launching with the
  fixed `setupAllowedTools` set (`Seihou.CLI.AgentRun.runRenderedAgentPrompt`). That set pre-approves
  only `Bash(seihou *)`, `Bash(git *)`, `Bash(ls *)`, `Bash(mkdir *)`, `Bash(cat *)`, `Bash(pwd)`,
  `Read`, `Write`, `Edit`, `Glob`, `Grep`, `EnterWorktree`, and `ExitWorktree`. Every other command
  this workflow needs — `mori`, `cabal`, `nix`, `psql`, `pg_dump`, `createdb`/`dropdb`, and the
  target's migration CLI — is not pre-approved and triggers an interactive approval prompt under
  claude-cli. For a destructive database workflow this prompting is a feature, not a defect: the
  operator sees each `dropdb`/`up` before it runs. The blueprint therefore declares no `allowedTools`
  (it would be dead metadata) and the prompt assumes a supervised session.
  Date: 2026-07-14

- Decision: Fold the pre-existing registry version drift fix into this change, and correct the
  expected debug-render transcript to Seihou's real output shape.
  Rationale: On the current tree `seihou registry validate` and `seihou registry sync-versions
  --check` already exit 1 because `modules.exec-plan` and `modules.master-plan` sit at `0.5.0` in
  `seihou-registry.dhall` while their `module.dhall` files are `0.6.0` (a bump from commit c43579b
  that never reached the registry). The plan's acceptance requires both commands to exit zero, so the
  drift must be reconciled with `seihou registry sync-versions` as part of this change. Separately,
  the first draft's expected debug block invented a variable-values section that Seihou does not
  emit; `renderSystemPrompt` produces `## Blueprint Identity` (`Name:`/`Version:`/`Description:`),
  `## Reference Files` (`  - <src> — <desc>`), and a `## Your Task` body that is `prompt.md` with
  `{{database.policy}}` substituted in place. The corrected transcript reflects that the policy value
  is visible only where the prompt interpolates it.
  Date: 2026-07-14

- Decision: Give the direct migration blueprint no base modules.
  Rationale: Unlike `hackage-release`, this blueprint does not generate and link an agent skill, so
  applying `agent-gitignore` would be an unrelated target-repository mutation. All required work
  belongs in the agent prompt and its bundled reference files.
  Date: 2026-07-14

- Decision: Treat the released 2026-07-14 package set as a known-good baseline, not an eternal
  definition of “latest.”
  Rationale: The blueprint must be useful after another release. It should discover dependencies
  with Mori, inspect current source and documentation, and select a coherent successor cohort when
  one exists; the pinned table remains a reproducible fallback and an API-migration checklist.
  Date: 2026-07-14

- Decision: Keep Rei's recorded `d17fcad24bdbd69765849c07c692615c58450872` revision as the
  provenance boundary for the portable field reports instead of silently refreshing to the newer
  local checkout.
  Rationale: The plan's extracted cutover lessons were reviewed against that recorded revision. A
  refresh would require revalidating the source plans and could change facts unrelated to this
  blueprint implementation. The reference corpus identifies the boundary and instructs future
  maintainers to record and revalidate any deliberate refresh.
  Date: 2026-07-15

- Decision: Retain the operationally self-sufficient prompt and omit `allowedTools` even though
  Seihou v0.4.0.0 can mount reference files and honor declared tools.
  Rationale: The same blueprint remains safe on v0.3.0.0, where references were not delivered and
  the field was ignored, while v0.4 users gain readable appendices automatically. Omitting the
  declaration on v0.4 keeps database, backup, build, and migration commands behind interactive
  approval, which is appropriate for this destructive workflow. The prompt conditionally reads a
  mounted reference directory and otherwise never depends on it.
  Date: 2026-07-15

- Decision: Keep the declarative `(ask|disposable|preserve)` interface for Seihou versions that
  implement it, and add a first-instruction prompt guard for v0.4.0.0.
  Rationale: The current CLI cannot express exact three-value validation in the Blueprint schema:
  unknown patterns pass, its only recognized pattern accepts many other slugs, and decoded `choice`
  variables carry no membership options. Changing the public values or patching another repository
  would exceed this blueprint's scope. The prompt guard preserves the safety property by stopping
  an invalid run before repository inspection, tool calls, or writes; validation-capable versions
  still reject before rendering.
  Date: 2026-07-15


## Outcomes & Retrospective

Summarize outcomes, gaps, and lessons learned at major milestones or at completion.
Compare the result against the original purpose. Before marking the plan complete,
distill durable project context from the Decision Log, Surprises & Discoveries, and
this section into docs/adr/. Keep task-local execution details here.

(To be filled during and after implementation.)


## Context and Orientation

Work from `/Users/shinzui/Keikaku/bokuno/agent-seihou`. The repository is a Seihou registry:
`seihou-registry.dhall` is its public module, recipe, blueprint, and prompt index, while the
root `README.md` explains how consumers browse, install, and run entries. There is no
`docs/adr/` directory and therefore no relevant ADR yet. If implementation produces a
durable repository convention beyond this blueprint, create an ADR during the final
distillation pass rather than placing task-local detail there.

The only current blueprint is `blueprints/hackage-release/`. Its `blueprint.dhall` shows the
schema import and `S.Blueprint` record shape; its `prompt.md` shows variable interpolation
such as `{{skill.name}}`; its `files/` directory shows how reference material is declared; and
its `README.md` shows the generated user-documentation format. The local skill
at `agents/skills/seihou-blueprint-readme/SKILL.md` is the authoritative procedure for
creating or refreshing a blueprint README. Follow that skill after the blueprint definition
and prompt stabilize. The target Seihou CLI observed while authoring this plan is
`v0.3.0.0 (411b302)`.

How Seihou v0.3.0.0 actually runs a blueprint (verified against the `shinzui/seihou` source at
`/Users/shinzui/Keikaku/bokuno/seihou-project/seihou`, and load-bearing for this plan):
`seihou agent run <name>` resolves variables with the standard precedence chain, optionally
applies `baseModules`, then renders a single system prompt and hands it to the provider. The
system prompt is assembled by `Seihou.CLI.AgentRun.renderSystemPrompt` from a fixed template
(`seihou-cli/data/blueprint-prompt.md`) with these blocks: `## Blueprint Identity` (three lines —
`Name:`, `Version:`, `Description:`), `## Baseline`, `## Reference Files`, and `## Your Task`
(which is `prompt.md` after `{{var}}` substitution). Three consequences shape this plan. First,
**the reference file contents are never inlined** — the `## Reference Files` block lists only each
file's basename and description, and the template tells the agent to "ask the user to provide it"
when a reference "is not shown in this prompt". Second, **the `files/` directory is not mounted**:
the provider's `--add-dir` list comes from `Baikai.Kit.Session.agentDirsForSession`, which returns
only `~/.config/<tool>/agents` and `<cwd>/.<tool>/agents`, so in a target repository the four
reference files are unreachable unless the operator supplies them by hand. Third, **there is no
rendered variable-values section** — a variable's value is visible only where `prompt.md`
interpolates it, so the prompt must print `{{database.policy}}` in prose for the selection to be
observable. Because of the first two consequences, `prompt.md` must carry every fact needed to run
the safe workflow inline; the `files/` references are appendices, not the primary channel.

Two more verified runtime facts. `seihou agent run` rejects the `anthropic`/`openai` API
providers for interactive sessions (they exit nonzero via
`Seihou.CLI.AgentLaunchExec.unsupportedInteractiveProvider`), so this blueprint requires
`--provider claude-cli` (the default) or `--provider codex-cli`. And the runner ignores a
blueprint's `allowedTools` field, always launching claude-cli with the fixed `setupAllowedTools`
allow-list (`Bash(seihou *)`, `Bash(git *)`, `Bash(ls *)`, `Bash(mkdir *)`, `Bash(cat *)`,
`Bash(pwd)`, `Read`, `Write`, `Edit`, `Glob`, `Grep`, `EnterWorktree`, `ExitWorktree`); every
other command the migration needs — `mori`, `cabal`, `nix`, `psql`, `pg_dump`,
`createdb`/`dropdb`, the target's migration CLI — surfaces an interactive approval prompt the
operator must accept. Treat that prompting as a safety gate, not an obstacle. `database.policy`
validation is a full-match regex (confirmed: `abc.def` is rejected against `[a-z][a-z0-9-]*`), so
`(ask|disposable|preserve)` accepts only those three exact values and rejects near-misses.

Current implementation environment update: the installed CLI is now Seihou `v0.4.0.0 (2aa69ce)`.
It mounts an existing blueprint `files/` directory into claude-cli/codex-cli sessions, renders the
readable path beneath `## Reference Files`, and honors `allowedTools` by merging declarations into
the fixed setup list. This blueprint deliberately remains compatible with the v0.3 behavior above:
the prompt is still self-sufficient, reads references only when the rendered prompt says they are
reachable, and declares no extra tools so migration/database commands remain interactive. Seihou
v0.4 also writes `.seihou/manifest.json` after a successful debug render, so all implementation
render probes must execute in a disposable temporary copy of this registry, not in the working
tree. Its `simplePatternMatch` also recognizes only the single literal
`[a-z][a-z0-9-]*` pattern and treats every other validation pattern as passing. Therefore
`(ask|disposable|preserve)` remains the public declaration for validation-capable versions, while
`prompt.md` must perform an immediate exact-value guard for v0.4 before any inspection or tool use.

Finally, the registry is already drifted before this plan begins: `seihou registry validate` and
`seihou registry sync-versions --check` both exit 1 today because `modules.exec-plan` and
`modules.master-plan` are `0.5.0` in `seihou-registry.dhall` but `0.6.0` on disk. This plan's
acceptance requires those commands to pass, so reconciling that drift with `seihou registry
sync-versions` is in scope for this change (it also fills in the new blueprint's version).

A **cohort** is a mutually compatible group of released packages, not simply the latest
version of `keiro`. The known-good Hackage snapshot has an `index-state` no earlier than
`2026-07-14T19:01:33Z`, the final upload time needed to see all PGMQ `0.4.0.1` packages. It
contains pg-migrate `1.1.0.0`; the five PGMQ packages at `0.4.0.1`; Keiro, Keiro Core,
Keiro Migrations, and Keiro PGMQ at `0.3.0.0`; Kiroku Store `0.3.0.1`; Kiroku Store
Migrations `0.3.0.0`; Kiroku CLI/Metrics/OTel at `0.2.0.0`/`0.1.0.1`/`0.2.0.1`;
Shibuya Kiroku Adapter `0.4.0.0`; Kioku API/Core/Migrations at `0.1.0.0`; Keiki and its JSON
codec at `0.2.0.0`; Shibuya Core/Metrics at `0.8.0.1`; Shibuya PGMQ Adapter `0.12.0.0`;
Shikumi/Cache/Trace at `0.3.0.0`/`0.1.2.0`/`0.2.0.0`; and hasql-notifications
`0.2.5.0`. A later coherent released set may replace this baseline only after the blueprint
agent uses Mori and the package source to verify the APIs and Cabal/Nix compatibility.

The five migration owners have a strict dependency order. PGMQ creates queue infrastructure.
Kiroku creates the event-store schema. Keiro builds framework tables on Kiroku. Kioku adds
memory and session schema on the framework. The target application contributes its own
component last when it owns SQL. Libraries export `MigrationComponent` values; the
application composes a validated `MigrationPlan`. Keiki has no database schema. Shibuya is a
runtime/adaptor dependency and does not add another component in this cohort.

The target runtime changes are coupled to migration adoption. Kiroku's process-scoped
`KirokuStoreResource` replaces older ad hoc `withStore`/`runStoreIO` ownership at long-lived
entry points. Keiro command runners accept `ValidatedEventStream`. Shibuya uses `AppConfig`,
`defaultAppConfig`, and handler-facing `Message`. Shibuya PGMQ Adapter construction starts
from `mkPgmqAdapterEnv`; `pgmqAdapter` receives that environment and returns `Either
PgmqConfigError ...`; Keiro PGMQ processors consequently need `Reader PgmqAdapterEnv` in
their effect rows. Kioku read models must be registered or reconciled once during runtime
acquisition. These are a compiler-guided checklist, not permission to guess signatures: the
blueprint must run Mori discovery first and read the selected package source.

pg-migrate owns the target ledger and is forward-only. Each owner embeds a strict checked-in
manifest with `embedMigrationManifest`; modules containing an embed use the GHC 9.12
`Database.PostgreSQL.Migrate.Embed.RecompilePlugin`. The application CLI exposes the
standard `plan`, `list`, `check`, `status`, `verify`, `up`, `repair`, and `new` behavior as
appropriate. `status` and `verify` are read-only. `verify` proves agreement between the
declared plan and ledger; it is not a live-schema diff, so every migration needs
application-specific schema and data assertions. Runtime bootstrap helpers must stop
creating framework schema after explicit migration ownership is established. An unrelated
bootstrap such as TypeID may stay outside the plan when no native component exists, but the
database preflight must run before any such writer.

The database decision is deliberately independent from code compilation. The blueprint must
classify a target as build-only/no database, fresh or disposable, exact predecessor history,
partial predecessor history, mixed native/imported history, or unsupported/ambiguous. A
disposable target gets a short path: confirm it is local, unshared, non-production, and safe
to erase; update the code and plan; reset only after explicit approval; run fresh `up`,
strict `verify`, a second no-op `up`, and an application smoke; then remove obsolete engines.
A data-bearing target gets a fail-closed path: inventory before writes, back up, quiesce
writers, rehearse on a restored clone, import exact predecessor history, run native pending
migrations, prove data invariants and idempotence, and only then schedule a real cutover.

History import is evidence, not a filename copy. Use `SamePayload` only when the preserved
source bytes exactly match the target manifest. Use `EquivalentState` only with an explicit
read-only validator and operator confirmation. Codd and hasql-migration histories use the
pg-migrate adapters and source locks documented by pg-migrate. PGMQ may share
`public.schema_migrations` with unrelated rows; PGMQ `0.4.0.1` supplies an explicit lenient
shared-ledger policy that still exposes unselected rows and supports equivalent-state
validation. Never delete or rewrite pg-migrate ledger rows. If a write made the state
unexpected, stop and recover from a pre-write backup or classify the truthful mixed state.

The implementation references must synthesize, not blindly copy, the following primary and
field-tested sources. The source revisions recorded during plan authoring are pg-migrate
`f39d64e354818999667d345a1452f33eb4857fc1`, Keiro
`29bd7952fa5201adf789bbb21427b2cffe228d4b`, Kioku
`a99aa369701a76278ca33d83f8416dee443fa645`, Mori
`d39cae1d8321ae5916152ac17cf3732ad0344f8b`, and Rei
`d17fcad24bdbd69765849c07c692615c58450872`. Re-run Mori and record newer revisions if the
implementation intentionally refreshes this baseline.

The pg-migrate source is `https://github.com/shinzui/pg-migrate`. Its essential files are
`docs/user/quickstart.md`, `manifest-authoring.md`, `component-authoring.md`,
`plan-composition.md`, `cli-integration.md`, and `testing.md`; and
`docs/operations/history-import.md`, `codd-import.md`, `hasql-migration-import.md`,
`deployment.md`, `locking-and-timeouts.md`, and `nontransactional-repair.md`. The Keiro source
is `https://github.com/shinzui/keiro`; read `docs/user/migrations.md`,
`migration-ownership.md`, `api-reference.md`, `command-cycle.md`, and
`docs/guides/migrating-to-validated-event-stream.md`. The Kioku source is
`https://github.com/shinzui/kioku`; its `docs/user/upgrading-to-pg-migrate.md` supplies one
exact Codd profile and its recovery rules, but its literal counts must not be generalized.

Mori's checked-in evidence is in
`/Users/shinzui/Keikaku/bokuno/mori-project/mori/docs/masterplans/19-migrate-mori-to-the-latest-keiro-kiroku-shibuya-cohort-and-adopt-pg-migrate.md` and plans `145`, `144`,
`140`, `139`, `138`, `137`, `143`, and `142` under `docs/plans/`. Plan 145 is the best compact
source for the released package set and five-component implementation; the other plans cover
PGMQ shared-ledger import, predecessor history, schema remediation, clone rehearsal,
single-runtime adoption, upstream release coordination, and legacy cleanup. Rei's
`docs/masterplans/19-migrate-rei-to-the-latest-keiro-kiroku-shibuya-cohort-and-complete-the-pg-migrate-cutover.md`,
`docs/plans/157-migrate-keiro-runtime-and-kioku-to-pg-migrate-safely.md`, and plans `165`
through `171` under `/Users/shinzui/Keikaku/bokuno/rei-project/rei/docs/plans/` supply the
disposable-dev, mixed-ledger, persistent-cutover, and cleanup lessons. Rei's older
`docs/dev/architecture/upgrading-the-keiro-kiroku-shibuya-stack.md` and `migrations.md`
describe a superseded Git-pin/Codd cohort and must be labeled historical rather than copied
as current guidance.

The agent-seihou Mori registry is intentionally sparse for these dependencies. At plan
authoring time `mori registry search keiro` found `shinzui/keiro`, while the other package
searches and `mori registry dependents shinzui/keiro --packages --json` returned no useful
entries. The blueprint must preserve the Mori-first rule and handle an absent registration
explicitly instead of pretending the lookup succeeded or searching `/nix/store`.


## Plan of Work

### Milestone 1: Author the portable reference corpus

Create `blueprints/migrate-keiro-stack/files/cohort-and-runtime-reference.md`. It must name
the known-good release table and index-state, explain how to locate a newer cohort through
Mori, distinguish migration owners from runtime-only packages, and describe the API
adaptation checklist. Include the rule that Cabal and Nix must resolve the same sources and
that compile errors plus selected dependency source are authoritative. Cite the upstream
repositories, source-document paths, and the recorded revisions above so later maintainers
can refresh facts without reverse-engineering their origin.

Create `blueprints/migrate-keiro-stack/files/pg-migrate-implementation-reference.md`. Make it
a concise application-authoring guide: preserve SQL bytes and filenames; add a strict
manifest; embed it with `embedMigrationManifest` and `RecompilePlugin`; export one
application `MigrationComponent`; resolve the upstream `pgmqMigrations`,
`kirokuMigrations`, `keiroMigrations`, and `kiokuMigrations`; compose them in dependency
order with the application last; mount the standard CLI; and test manifest integrity,
dependency errors, fresh apply, verify, and no-op reapply. Explain that literal component
counts come from the selected manifests and must never be copied from Mori or Rei. Include
the distinction between plan/ledger verification and live-schema validation.

Create `blueprints/migrate-keiro-stack/files/disposable-database-fast-path.md`. It should be
the simple guide requested for non-production projects: classify the database, require an
affirmative answer that it is unshared and safe to erase, complete the build/runtime/plan
work before destruction, recreate the database, apply the production plan, verify, reapply
with zero work, smoke test, then remove Codd/hasql/legacy runners. Include explicit stop
conditions for a non-empty target ledger, unknown predecessor rows, a non-local connection,
or any uncertainty about data ownership. Do not prescribe a particular `dropdb` command;
the agent must use the target project's own database lifecycle and ask before running it.

Create `blueprints/migrate-keiro-stack/files/persistent-database-cutover.md`. It must cover
read-only inventory before target-ledger initialization, exact/partial/mixed/ambiguous state
classification, pre-write backup, writer quiescence, restored-clone rehearsal, Codd and
hasql adapters, PGMQ shared-ledger policy, `SamePayload` versus `EquivalentState`, schema
relocation and Kioku registry reconciliation, exact pending-ID oracles, data/row-count
assertions, strict verify, no-op second run, application smoke, production soak, and delayed
cleanup. State that restore is the rollback and direct target-ledger edits are forbidden.

Each file is a portable synthesis, not a dump of a project plan. It should include enough
commands and Haskell shapes to guide an agent but replace Mori/Rei application names,
counts, URLs, table inventories, and environment variables with discovery instructions.

Because Seihou v0.3.0.0 does not deliver `files/` content to the running agent (see Context and
Orientation), treat these four files as deeper appendices, not as the agent's primary channel.
The load-bearing essentials they contain — the known-good cohort table and index-state, the
ordered `pgmq -> kiroku -> keiro -> kioku -> application` plan, both database branches with their
stop conditions, and the Mori-first discovery and forbidden-action rules — must be duplicated
inline in `prompt.md` in Milestone 2 so the workflow is safe even when the files are unreachable.
Keep the two in agreement; the files may go deeper, but they must not contradict the prompt.

This milestone is accepted when all four files exist, have no unresolved absolute-path
dependency in their operational instructions, and collectively cover every source listed
in Context and Orientation.

### Milestone 2: Define the adaptive blueprint and prompt

Create `blueprints/migrate-keiro-stack/blueprint.dhall` using the same pinned Seihou schema
import as `blueprints/hackage-release/blueprint.dhall` (copy the `let S = https://...` line and
its `sha256:` verbatim — it is `a0fba0d17b43b14bfdf6d0bf98f1b7ff7af4ebab`). Define name
`migrate-keiro-stack`, version `Some "0.1.0"`, an accurate description, `prompt = ./prompt.md as
Text`, and tags for Haskell, PostgreSQL, pg-migrate, Keiro, Kiroku, Kioku, Shibuya, and PGMQ. Omit
`baseModules` entirely so it takes the schema default (`[] : List Dependency.Type`); do not write a
bare `[]`, which fails to type-check without an annotation. Do not set `allowedTools`: the runner
ignores it (see Context and Orientation), so leaving it at its `None` default keeps the definition
honest. Add one required text variable with `S.VarDecl::{ name = "database.policy", type = "text",
default = Some "ask", required = True, validation = Some "(ask|disposable|preserve)" }`. Add four
`S.Blueprint.BlueprintFile::{ src = ..., description = Some ... }` entries whose `src` values are the
exact basenames under `files/` and whose descriptions tell the agent when each reference applies.

Create `blueprints/migrate-keiro-stack/prompt.md` as an adaptive implementation workflow. This
prompt is the primary channel and must be operationally self-sufficient: because Seihou does not
deliver `files/` content to the agent, `prompt.md` itself must carry the known-good cohort baseline
table and index-state, the ordered five-component plan, both database branches with their stop
conditions, the Mori-first discovery rule, and the forbidden-action list. Reference the four `files/`
documents by name for deeper detail, but instruct the agent to read them only if they are actually
reachable in its working directory or provided by the operator, to ask the operator to paste a
reference it cannot read, and to never fabricate or claim to have read reference content. Print the
selected policy in prose as `Database policy: {{database.policy}}` near the top so the choice is
observable in a debug render (Seihou renders no separate variable-values block).

Start by telling the running agent to read target-repository instructions, preserve existing
changes, avoid a feature branch unless requested, and use Mori before dependency APIs: run
`mori show --full` when `mori.dhall` exists, search/show registered dependencies, then read
their source and docs. If a dependency is not registered, record that fact and use the
target's lockfiles/package metadata plus an explicitly located checkout or published source;
never guess APIs and never inspect `/nix/store`. Also state that the run must use a tool-capable
interactive provider (`--provider claude-cli` default, or `codex-cli`) and that commands beyond the
pre-approved `seihou`/`git`/`ls`/`mkdir`/`cat`/`pwd`/Read/Write/Edit/Glob/Grep set — notably
`mori`, `cabal`, `nix`, `psql`, `pg_dump`, `createdb`/`dropdb`, and the target's migration CLI —
will prompt for interactive approval, which the operator must grant deliberately.

The prompt's discovery phase must inventory build systems, Cabal packages, Nix sources,
current cohort versions, old source pins, migration directories, all schema writers,
existing ledgers, runtime entry points, test commands, database URLs by role, and local
instructions. It should determine whether the project owns an application component and
whether helpers such as TypeID remain outside the native plan. It must inspect actual
manifests and source ledgers to derive component counts and supported imports.

The prompt must interpret `{{database.policy}}`. Under `ask`, classify from read-only
evidence and ask one focused question only if erasure/preservation intent remains unclear.
Under `preserve`, forbid writes to a data-bearing database until the project has a reviewed
plan and successful restored-clone rehearsal. Under `disposable`, still verify that the URL
is local/unshared/non-production and ask immediately before erasing it. If evidence
contradicts the selected policy, stop and report the contradiction.

After classification, the prompt should implement four separable tracks. First, replace
workstation-local or stale source pins with one coherent cohort and make Cabal/Nix agree.
Second, adapt Kiroku/Keiro/Shibuya/PGMQ/Kioku runtime APIs using selected source and compiler
errors. Third, create the strict application manifest/component, ordered five-component
plan, explicit CLI, integrity tests, and runtime bootstrap boundary. Fourth, execute either
the disposable fast path or the persistent rehearsal/cutover path. The build-only case
stops after database-free plan rendering and clearly lists the remaining operator work.

The prompt must forbid speculative `up`, automatic production writes, schema initialization
hidden inside normal application startup, copying cohort counts from examples, manual edits
to `pgmigrate.migrations`, and deleting old migration engines before the new plan has passed
its selected database proof. It should require a second `up` that applies zero work, strict
verify, live-schema/data assertions, and a representative application read/write smoke. It
must offer a commit only after checks pass, follow the target's commit rules, and never push
without authorization.

This milestone is accepted when `seihou validate-blueprint
blueprints/migrate-keiro-stack --lint` passes and a debug render shows the selected policy,
all four reference descriptions, the five-component order, and both safety branches.

### Milestone 3: Publish registry documentation

Add a `migrate-keiro-stack` entry at version `0.1.0` to the `blueprints` list in
`seihou-registry.dhall`. Match the blueprint's description and tags closely enough that a
registry consumer can distinguish it from `hackage-release`. Do not add it to
`mori.dhall`: the current Mori project metadata already exposes the Seihou registry as a
repository, while `seihou-registry.dhall` is the authoritative blueprint catalog.

Use `agents/skills/seihou-blueprint-readme/SKILL.md` to create
`blueprints/migrate-keiro-stack/README.md` after validating the definition. The README must
explain what the agent does, show the default and explicit policy invocations, document the
`database.policy` values, list the reference files, describe the no-baseline behavior, note that it
requires an interactive `claude-cli`/`codex-cli` session, and state the destructive/persistent-data
guardrails. Update the root `README.md` blueprint table and usage examples with the new entry.

Reconcile the registry version drift as part of this change: `seihou registry validate` and
`seihou registry sync-versions --check` already fail on the current tree because
`modules.exec-plan` and `modules.master-plan` read `0.5.0` in `seihou-registry.dhall` while their
`module.dhall` files are `0.6.0`. After adding the blueprint entry, run `seihou registry
sync-versions` (without `--check`) to write the correct versions for both the new blueprint and the
two drifted modules, then re-run the checks. This is incidental cleanup, not a feature; note it in
the commit body so the exec-plan/master-plan bumps are not mistaken for part of the blueprint.

This milestone is accepted when the blueprint README is consistent with `blueprint.dhall`,
the root catalog links to it, `seihou registry sync-versions --check` reports no mismatch (exit
0), and `seihou registry validate` passes (exit 0).

### Milestone 4: Prove both workflow branches and finalize

Run the blueprint renderer with default, disposable, and preserve policies. Save temporary
rendered output outside the repository or inspect the debug transcript without committing
it. Confirm that the disposable render cannot bypass confirmation, the preserve render
cannot write before clone proof, and neither render depends on the authoring machine's
absolute Mori/Rei paths. Check that the rendered task body and the reference files describe the
current known-good cohort while instructing the running agent to rediscover a newer one, and that
the safe workflow in the task body does not depend on any reference file being read.

Perform a text-level scenario review using two imaginary target states. The first is a
single-package service with an empty local database and no production deployment: the
workflow should upgrade, create the plan, request reset confirmation, apply, verify,
reapply with zero work, and smoke without demanding history-import rehearsal. The second is
a service with Codd and hasql rows plus unrelated PGMQ rows in a shared source ledger: the
workflow should stop before target-ledger writes, select the preserve path, require a
backup/restored clone, use component-specific imports and PGMQ's shared-ledger policy, and
retain old runners until soak. Record any ambiguity discovered during this review in this
ExecPlan and fix the prompt or references.

Run formatting if the repository has a configured formatter, re-run all Seihou validation,
review `git diff --check`, and update Progress, Surprises & Discoveries, Decision Log, and
Outcomes & Retrospective. Distill only durable repository-wide lessons into `docs/adr/`.
Commit with a Conventional Commit subject and the required ExecPlan trailer.


## Concrete Steps

Work from the agent-seihou root and capture the clean/dirty baseline before editing:

```bash
cd /Users/shinzui/Keikaku/bokuno/agent-seihou
git status --short
mori show --full
mori registry search keiro
mori registry show shinzui/keiro --full
```

Expected Mori identity includes this repository and may find only Keiro among the relevant
dependencies:

```text
identity: shinzui/agent-seihou
...
shinzui/keiro  /Users/shinzui/Keikaku/bokuno/keiro
```

Create the directory and files through patches, not shell redirection:

```text
blueprints/migrate-keiro-stack/
├── README.md
├── blueprint.dhall
├── prompt.md
└── files/
    ├── cohort-and-runtime-reference.md
    ├── disposable-database-fast-path.md
    ├── persistent-database-cutover.md
    └── pg-migrate-implementation-reference.md
```

Validate the definition before generating its README:

```bash
seihou validate-blueprint blueprints/migrate-keiro-stack --lint
```

Expected result is a zero exit status and no missing prompt, variable, base, or file errors.
Then follow `agents/skills/seihou-blueprint-readme/SKILL.md` to author the README and run the
same validation again.

Render all policy modes without applying a baseline:

```bash
seihou agent --debug run migrate-keiro-stack --no-baseline
seihou agent --debug run migrate-keiro-stack --no-baseline --var database.policy=disposable
seihou agent --debug run migrate-keiro-stack --no-baseline --var database.policy=preserve
```

The debug output is the fully rendered system prompt. It is structured as `## Blueprint Identity`
(three lines), `## Baseline`, `## Reference Files` (basename + description per file), then `## Your
Task` containing `prompt.md` with `{{database.policy}}` already substituted. Seihou does not emit a
separate variable-values section, so the policy is visible only in the task body. Expect blocks
equivalent to:

```text
## Blueprint Identity

Name: migrate-keiro-stack
Version: 0.1.0
Description: <the blueprint description>

## Baseline

(no baseline applied — `--no-baseline` was passed)

## Reference Files

  - cohort-and-runtime-reference.md — <description>
  - pg-migrate-implementation-reference.md — <description>
  - disposable-database-fast-path.md — <description>
  - persistent-database-cutover.md — <description>

## Your Task

... Database policy: ask ...
```

For the `--var database.policy=disposable` and `--var database.policy=preserve` renders, the same
`Database policy:` line reads `disposable` or `preserve` respectively, and the disposable/preserve
branch prose is present in the task body. Confirm the reference-file basenames and descriptions
match `blueprint.dhall`.

Probe an invalid policy to prove the version-appropriate guard is active:

```bash
seihou agent --debug run migrate-keiro-stack --no-baseline --var database.policy=production
```

On Seihou v0.3.0.0, expected output contains a validation error and the process exits nonzero. On
Seihou v0.4.0.0, arbitrary patterns are not enforced, so the debug render exits zero but the first
lines of `## Your Task` must say that a policy other than `ask`, `disposable`, or `preserve` is
invalid and requires stopping before repository inspection, tool calls, or changes. In either case,
an invalid policy must not reach migration work.

Reconcile the registry, then validate it and the working tree. The first `sync-versions` run
writes the new blueprint's version and also clears the pre-existing `exec-plan`/`master-plan`
`0.5.0 -> 0.6.0` drift (see Context and Orientation); without it the `--check` and `validate`
commands below exit 1 as they do on the untouched tree:

```bash
seihou registry sync-versions
seihou registry sync-versions --check
seihou registry validate
git diff --check
git status --short
```

Expected output: the first command reports the blueprint and the two module rows updated; then
`--check` and `validate` both exit 0 with no remaining drift or invalid entry, and `git diff
--check` reports no whitespace error. Review the final diff (it should touch only this blueprint's
files plus the two incidental module-version rows), update this living document, and commit:

```text
feat(blueprint): add Keiro stack pg-migrate workflow

ExecPlan: docs/plans/1-add-an-adaptive-pg-migrate-keiro-stack-blueprint.md
```


## Validation and Acceptance

Acceptance is behavioral, not merely valid Dhall. The default render must teach an agent to
inspect the target before choosing a database path. A `database.policy=disposable` render
must contain the local/unshared/non-production classification, an explicit destructive
confirmation, a fresh apply, strict verify, a second zero-work apply, and a real application
smoke. It must not require legacy import or a production soak when the database is proven
disposable.

A `database.policy=preserve` render must prohibit target-ledger initialization before
inventory and backup, require a restored-clone rehearsal, distinguish exact, partial, mixed,
and ambiguous history, use the relevant Codd/hasql/PGMQ import policy, preserve truthful
native prefixes, assert live schema and data, and delay cleanup until production soak. It
must state that restore is rollback and that direct ledger edits are unsupported.

Every render must identify PGMQ, Kiroku, Keiro, Kioku, and the application as ordered
migration components; distinguish Keiki and Shibuya as non-component dependencies; mention
`KirokuStoreResource`, `ValidatedEventStream`, `AppConfig`, `PgmqAdapterEnv`, and Kioku
read-model registration as runtime inspection points; require Mori-first API discovery;
align Cabal and Nix; and derive migration counts from manifests rather than examples. Because
Seihou does not deliver `files/` content to the agent, all of this must be present in the rendered
`## Your Task` body (that is, inline in `prompt.md`), not only in the reference files — a render
whose safe workflow depends on an unread file fails acceptance.

The four reference files must be understandable without access to the Mori or Rei
worktrees. They may cite repository URLs, exact source paths, and revisions for provenance,
but no instruction may require an absolute `/Users/shinzui/...` path. The prompt must instruct the
agent to read them only when reachable and to ask the operator to paste any it cannot read, never
to fabricate their content. The README and root catalog must accurately describe the variable, the
references, the safety split, the interactive-provider requirement, and the invocation.

Finally, all of the following must exit zero after the registry reconciliation step (`seihou
registry sync-versions`) has run: `seihou validate-blueprint blueprints/migrate-keiro-stack
--lint`, `seihou registry sync-versions --check`, `seihou registry validate`, and `git diff
--check`. The invalid `database.policy=production` probe must either exit nonzero before rendering
(validation-capable Seihou) or render the immediate prompt-level stop guard documented above
(Seihou v0.4.0.0). Run debug rendering in a disposable temporary registry copy because v0.4 writes
successful debug provenance; the render must not modify the real target repository or connect to a
database.


## Idempotence and Recovery

Blueprint validation, registry validation, debug rendering with `--no-baseline`, README
regeneration from the settled definition, and the scenario review are repeatable. Re-run
them after every prompt or reference change. The blueprint has no base module, so debug
rendering should not create target files before an agent begins work.

During implementation, preserve unrelated changes in the shared worktree. If a generated
README conflicts with hand edits, reconcile it against `blueprint.dhall` and `prompt.md`
rather than discarding the user's text. If the registry version and blueprint version drift,
fix the authoritative blueprint definition first and run `seihou registry sync-versions
--check` again; do not bump versions merely to silence a check.

The implemented blueprint itself must encode stronger recovery rules. Its disposable path
can be retried by recreating the explicitly confirmed local database and applying the same
immutable plan. Its persistent path is retryable on a fresh restoration of the pre-write
backup. Once pg-migrate records a successful native or imported row, that row is an audit
fact: never delete, update, or relabel it. Stop on a partial run, preserve evidence, and
reclassify the database as mixed before continuing with supported component-aware imports.


## Interfaces and Dependencies

The new Seihou interface is the blueprint record at
`blueprints/migrate-keiro-stack/blueprint.dhall`. It uses the existing pinned
`seihou-schema` import and `S.Blueprint::{ ... }` record. Its public variable is:

```text
name: database.policy
type: text
default: ask
required: true
validation: (ask|disposable|preserve)
```

Validation-capable Seihou versions reject other values before rendering. Seihou v0.4.0.0 treats
this arbitrary pattern as unknown and therefore permissive, so the rendered prompt repeats the
three-value check as its first instruction and forbids inspection or tool calls on any other value.

The blueprint files interface is four `S.Blueprint.BlueprintFile` records whose `src`
values exactly match the basenames in `blueprints/migrate-keiro-stack/files/`. The prompt
reads the selected value as `{{database.policy}}`. `baseModules` is omitted so it defaults to the
empty list (`[] : List Dependency.Type`); a bare `[]` will not type-check. `allowedTools` is left
unset (`None`): the blueprint runner ignores it and always launches with the fixed
`setupAllowedTools` set, so declaring it would be dead metadata. The registry interface is a
matching `blueprints` entry in `seihou-registry.dhall`, and the user interfaces are the
per-blueprint README and root blueprint table.

The runtime interface Seihou provides to the running agent is a single rendered system prompt plus
the target repository as the working directory; the blueprint's own `files/` directory is not
added to the agent's accessible paths. The blueprint therefore requires a tool-capable interactive
provider — `--provider claude-cli` (default) or `--provider codex-cli`; the `anthropic` and
`openai` API providers are rejected for interactive runs. Tools outside the pre-approved
`setupAllowedTools` set (`mori`, `cabal`, `nix`, `psql`, `pg_dump`, `createdb`/`dropdb`, the
target's migration CLI) surface interactive approval prompts, which for this destructive workflow
are a deliberate safety gate.

The reference corpus must teach, but does not itself compile against, the pg-migrate public
surface. Use the selected source to verify the current signatures in
`Database.PostgreSQL.Migrate`, `Database.PostgreSQL.Migrate.Embed`,
`Database.PostgreSQL.Migrate.Cli`, `Database.PostgreSQL.Migrate.History.Codd`, and the
hasql-migration history adapter. The architectural shapes to preserve are:

```haskell
applicationMigrations :: Either DefinitionError MigrationComponent
applicationPlan :: Either DefinitionError (Either PlanError MigrationPlan)
```

The component definition embeds a checked-in manifest using
`embedMigrationManifest`, and its module carries:

```haskell
{-# OPTIONS_GHC -fplugin=Database.PostgreSQL.Migrate.Embed.RecompilePlugin #-}
```

The plan resolves the selected releases' PGMQ, Kiroku, Keiro, and Kioku components and
places the application component last. Reference pseudocode may show the order, but it must
tell the agent to read the actual exported constructors before naming imports because those
are dependency APIs. The running migration CLI must expose an explicit subcommand and must
not interpret a bare invocation as `up`.

The runtime dependencies to identify in target source are `KirokuStoreResource` in the
Kiroku/Keiro boundary, `ValidatedEventStream` in Keiro, `AppConfig`, `defaultAppConfig`, and
`Message` in Shibuya, `PgmqAdapterEnv`, `mkPgmqAdapterEnv`, and `PgmqConfigError` in
Shibuya PGMQ Adapter, and Kioku's read-model registration/reconciliation API. These names
are search anchors. Exact modules, effect rows, and signatures come from the cohort selected
through Mori and must be recorded in the target project's plan or implementation notes.

No live PostgreSQL service is required to implement or validate this blueprint. Seihou
`v0.3.0.0` or a compatible successor is required for `validate-blueprint`, registry checks,
and debug rendering. Mori is required for dependency discovery in repositories that use the
Mori ecosystem; an absent registry entry is a recorded limitation, not a reason to search
`/nix/store` or guess.


## Revision Notes

- 2026-07-14 — Close validation pass against the running toolchain, prompted by the intent to reuse
  this blueprint across many project migrations. Every claim about the Seihou CLI, the Blueprint
  schema, and the blueprint-run mechanics was checked against `seihou v0.3.0.0 (411b302)` and the
  `shinzui/seihou` and `shinzui/baikai` source. Confirmed working: the `agent run --var`,
  `--no-baseline`, and parent `--debug` flags; `validate-blueprint --lint`; dotted variable names;
  full-match `validation` regex enforcement (exit 1 on mismatch); and the `registry sync-versions
  --check` / `registry validate` commands. Findings that changed the plan:
  (1) **Reference files are not delivered to the running agent.** `renderSystemPrompt` lists only
  each file's basename and description and never inlines contents, and `agentDirsForSession` mounts
  only `~/.config/<tool>/agents` and `<cwd>/.<tool>/agents`, never the blueprint's `files/`. The
  original design assumed Seihou "mounts blueprint files into the agent context," which is false.
  Corrected the Decision Log, Context and Orientation, Milestones 1–2, Validation, and Interfaces so
  `prompt.md` is operationally self-sufficient and the `files/` documents are supplementary
  appendices the agent reads only when reachable and never fabricates.
  (2) **The expected debug transcript was inaccurate.** Seihou emits `## Blueprint Identity` /
  `## Reference Files` / `## Your Task` and no variable-values section; the policy is visible only
  where `prompt.md` interpolates `{{database.policy}}`. Rewrote the Concrete Steps transcript and
  added the requirement that the prompt print `Database policy: {{database.policy}}` in prose.
  (3) **Registry checks already fail on the untouched tree** (`exec-plan`/`master-plan` at `0.5.0`
  in the registry vs `0.6.0` on disk). Since acceptance requires them to pass, folded a `seihou
  registry sync-versions` reconciliation into Milestone 3 / Concrete Steps and flagged the two module
  rows as incidental cleanup to call out in the commit.
  (4) **Provider and tool constraints made explicit.** The API providers are rejected for
  interactive runs, and the runner ignores a blueprint's `allowedTools`, always using the fixed
  `setupAllowedTools` set — so `mori`/`cabal`/`nix`/`psql`/`pg_dump`/`createdb`/`dropdb`/the target
  CLI prompt for interactive approval. Recorded this as a required interactive-provider dependency
  and a deliberate safety gate, and specified omitting `allowedTools` (dead metadata) and omitting
  `baseModules` (schema default; a bare `[]` will not type-check).
