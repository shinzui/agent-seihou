# docs-sync

> Discover a project's documentation and agent-context surfaces, then audit and repair every stale surface against the code using a baseline-SHA ledger. The workflow adapts to local prose, embedded or runtime-loaded CLI help, embedded agent-assist context, and confirmed sibling kit or public-docs repositories instead of assuming a fixed project layout.

**Version:** `0.1.0`

**Kind:** Blueprint (agent-driven — run with `seihou agent run`, not `seihou run`)

## Overview

This blueprint discovers the documentation topology of the target repository before changing it,
then performs a baseline-driven accuracy and coverage audit against authoritative source and CLI
behavior. It supports repositories with only local prose as well as projects that ship CLI help,
agent-assist context, a sibling kit, or a separate public-docs site.

## Variables

| Name | Type | Default | Required | Validation | Description |
|------|------|---------|----------|------------|-------------|
| `sync.scope` | `text` | `all` | yes | — | Audit every stale discovered surface, or a comma-separated list of ledger surface keys. |
| `external.policy` | `text` | `discover` | yes | `(discover\|local-only)` | Discover and sync confirmed sibling repositories, or restrict edits to the current repository. |

## Baseline

This blueprint declares no base modules.

## Reference Files

Mounted read-only and listed in the agent's prompt as adaptable source material:

- `files/capability-discovery.md` — Evidence rules for local docs, CLI help transport, embedded agent context, and sibling repository ownership.
- `files/ledger-reference.md` — Portable ledger shape, baseline invariants, staleness rules, and local/external examples.

## What the agent produces

The agent writes or updates `docs/docs-sync.json`, reports the discovered surface map, audits only
the requested stale surfaces, repairs deterministic and prose drift, and runs project-appropriate
validation. Optional sibling repositories are edited only after their relationship is confirmed;
absent surfaces remain a supported project shape and unaudited baselines never advance.

## Usage

Run in the target repository:

```bash
seihou agent run docs-sync
```

With variable overrides, or skipping the baseline:

```bash
seihou agent run docs-sync --var sync.scope=readme,cli-help
seihou agent run docs-sync --var external.policy=local-only
seihou agent run docs-sync --no-baseline
```

Print the resolved agent system prompt without launching the agent (no side effects):

```bash
seihou agent --debug run docs-sync --no-baseline
```

## Tags

`documentation`, `docs`, `cli`, `agents`, `skills`, `drift`, `audit`

## See Also

- `blueprint.dhall` — full blueprint definition and authoritative source
- `prompt.md` — the agent task prompt
- `files/` — read-only reference material
