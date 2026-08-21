# Synchronize documentation and agent context

Audit and repair the documentation shipped by the repository in which this blueprint is
running. Work from evidence in the target repository: do not assume its language, package layout,
documentation taxonomy, executable name, or that it has the same surfaces as another project.

The requested scope is `{{sync.scope}}`. The external-repository policy is
`{{external.policy}}`.

Read the mounted `capability-discovery.md` and `ledger-reference.md` before acting. They define
what counts as a confirmed surface and what a baseline means.

## Non-negotiable rules

1. Read and obey the target repository's agent instructions before inspecting or changing it.
   When a confirmed sibling repository enters scope, read that repository's instructions too.
2. Preserve unrelated work in every checkout. Report dirty files before editing and never discard,
   overwrite, or reformat unrelated changes.
3. Verify documentation claims against source code, tests, generated schemas, or a binary built
   from the audited worktree. Another document is not an authoritative source.
4. A surface baseline is a claim that the surface was actually audited against that source commit.
   Never advance a baseline for discovery alone, a mechanical-only pass, a skipped surface, or a
   partial pass recorded as full.
5. Do not scan `/`, a home directory, or package-manager stores to find related repositories or
   dependencies. Keep filesystem discovery within the repository and its narrow project-group
   parent. Use the target's dependency/registry lookup instructions when present.
6. Never push. Commit only when the user's request or a repository instruction explicitly requires
   it; otherwise leave reviewable changes in each checkout and report them separately.

## Phase 1: establish the source snapshot

Resolve the repository root and capture, before documentation edits:

- the full source `HEAD` SHA and commit date;
- current branch and worktree status;
- project identity and canonical project URI when discoverable;
- build/test/format commands from repository instructions and manifests;
- the exact command needed to build and interrogate each shipped CLI, if one exists.

Call this immutable SHA the **audited source HEAD**. Documentation-only commits created later in the
run do not change which source revision was audited.

Read `docs/docs-sync.json` if it exists. Preserve compatible project-specific fields and notes. If
it does not exist, plan to create it from the reference shape after capability discovery; every new
surface starts with `sourceBaseline: null` and `coverage: "never"`.

## Phase 2: discover capabilities and surfaces

Re-probe capabilities on every run, including capabilities previously recorded as absent. Follow
the evidence ladder in `capability-discovery.md` and inspect at least:

- repository landing and guide prose such as README files, user guides, architecture/design docs,
  changelogs, and maintained agent instructions;
- the real CLI parser/router and its exact `--help` surface, when the project ships a CLI;
- help assets and their complete delivery path: source file, embed or runtime loader, topic/command
  registration, package/build inclusion, and user-reachable command;
- agent-facing commands and their standing context: prompt assets, embedding or runtime loading,
  dispatch from commands such as assist/bootstrap/setup/agent flows, and package/build inclusion;
- local skill, subagent, prompt, or kit catalogs whose guidance describes the product;
- with `external.policy=discover`, explicit or strongly evidenced sibling kit and public-docs
  repositories.

Do not infer a surface from a suggestive directory name alone. Record `confirmed`, `absent`, or
`ambiguous` with evidence. Only confirmed capabilities become auditable surfaces. If multiple
sibling candidates remain plausible after read-only inspection, ask one focused question before
editing any of them. If no sibling is confirmed, continue with local surfaces; absence is a normal
project shape, not an error.

Compare discovery with the existing ledger:

- add newly confirmed surfaces at `coverage: "never"`;
- refresh capability evidence and checkout hints without changing baselines;
- retain a surface whose files disappeared, mark the capability ambiguous or absent, and investigate
  whether the product intentionally removed it before retiring anything;
- never silently delete ledger history.

Before mutation, report a compact surface table with key, repository, transport/kind, discovery
evidence, baseline, commits in range, coverage, and whether it is in `{{sync.scope}}`.

## Phase 3: determine staleness

For every selected surface, evaluate commits touching its capability-derived `watch` paths from
`sourceBaseline` through the audited source HEAD. A null baseline means the whole surface has never
been audited: read it in full. If a recorded SHA is unavailable, report a history gap and treat the
surface as requiring a full audit; do not invent a replacement baseline.

`sync.scope=all` means every stale confirmed surface. A comma-separated value selects exactly those
keys; discovery still runs, but unselected baselines do not move. Reject unknown keys with the list
of discovered keys rather than guessing.

For confirmed external surfaces, also compare their recorded `targetBaseline` with the current
target-repository HEAD. Target-side edits may need reconciliation even when the source watch paths
did not change.

If a surface has an unusually large or never-audited range, state the honest scope before reading
it. Continue unless repository instructions require approval or the user narrows the scope.

## Phase 4: run evidence-derived mechanical checks

Use an existing project-specific drift checker when it is trustworthy and inspect what it covers.
Otherwise run focused comparisons from the discovered topology. Add or improve a maintained checker
only when the repository already has a suitable home and the check expresses a durable certainty.

Mechanical checks should cover each applicable invariant, not a hard-coded technology:

- content file ↔ loader/embed declaration ↔ registry/router ↔ package/build inclusion;
- registered help topics and aliases ↔ user-reachable CLI output;
- agent-context assets ↔ the assist/agent command paths that consume them;
- prose citations of commands, flags, help topics, recipes, pages, and skills ↔ their authoritative
  inventories;
- guide files ↔ navigation/index manifests;
- kit skill/agent files ↔ catalog entries, declared files, and mirrored versions;
- built CLI command inventory ↔ public command pages, when a public-docs sibling is confirmed.

Classify deterministic mismatches as drift and fix them. A check that cannot decide ownership or
intent is a note for the accuracy audit, not an automatic rewrite. Mechanical success never proves
the prose is true.

## Phase 5: build a behavioral claim inventory

From the oldest selected source baseline, inspect the complete behavioral range, not only commits
that touched documentation. Include feature, fix, breaking, configuration/schema, command-parser,
and agent-workflow changes. Read diffs in the actual source paths and inspect submodule or generated
schema changes at their underlying revisions rather than treating a pointer bump as the change.

Turn the range into a claim list. Each claim records:

- the source commit or source location that proves it;
- the externally observable behavior, command/flag/default, workflow, or architecture fact;
- which discovered surfaces should cover it and why;
- whether the current prose is correct, missing, misleading, or intentionally silent.

Internal refactors may need no user documentation, but they can still invalidate architecture docs
or standing agent instructions. Record that decision instead of assuming all refactors are irrelevant.

## Phase 6: audit and repair each selected surface

Read the selected surface against the claim list and the current authoritative implementation.
Match the surface's purpose:

- landing pages stay concise and route readers to deeper material;
- CLI help is terse and exact about syntax, flags, defaults, aliases, and reachability;
- user guides explain workflows and connect exact reference material;
- architecture docs explain current design and clearly label genuinely planned or historical text;
- agent-assist context prescribes commands, help topics, and workflows that still work;
- kit skills and subagents preserve their catalog/version rules and teach current product behavior;
- public-docs siblings preserve their own framework, navigation, validation, and publishing rules.

Add missing coverage when a shipped behavior has no appropriate topic/page; do not limit the pass to
editing existing prose. Follow cross-references far enough to verify the destination actually supports
the claim. Build the CLI from the audited worktree before treating its output as exact, and note any
case where the available executable cannot be proven to match the audited source HEAD.

When editing a sibling repository, use its canonical project URI in durable cross-repository
references. Keep checkout paths as local operational hints only. Do not touch an ambiguous sibling.

## Phase 7: verify

Run, as applicable:

- the target's documentation/site validation;
- compilation or packaging checks that prove embedded help and agent-context assets still ship;
- exact CLI help/topic invocations affected by the edits;
- kit catalog/version validation;
- the mechanical drift checks again;
- repository formatter and proportionate tests.

Report failures rather than weakening checks or advancing affected baselines.

## Phase 8: record honestly

Update `docs/docs-sync.json` only after verification:

- set `sourceBaseline` to the audited source HEAD only for surfaces actually audited;
- set the date and `coverage` to `full` or `partial` honestly;
- explain partial scope and unresolved findings in `notes`;
- set `targetBaseline` for external surfaces to the sibling HEAD actually audited;
- retain discovery evidence and portable canonical repository identity;
- update a schema/submodule baseline only when its underlying diff was reviewed.

If the project already keeps a narrative docs-sync changelog, append an entry in its established
format. Do not invent a second changelog merely for bookkeeping; the JSON ledger is required, the
narrative is project-dependent.

## Final report

Lead with the outcome, then include:

1. discovered capabilities, including confirmed absent or ambiguous optional surfaces;
2. staleness and audited commit ranges per selected surface;
3. mechanical findings fixed and remaining;
4. accuracy/coverage findings and files changed, grouped by repository;
5. verification results;
6. ledger baselines advanced, partial, or deliberately unchanged;
7. anything not done and the exact reason.

Do not claim “docs are synced” while a selected surface is partial, unverified, or still has an
unresolved deterministic drift finding.
