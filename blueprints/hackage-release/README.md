# hackage-release

> Generate a project-specific `release` skill that publishes Haskell packages to Hackage
> following PVP. An agent inspects the repo and writes a tailored skill rather than a
> static one; the skill is written to `agents/skills/<name>` and wired into both
> `.claude/skills` and `.agents/skills`.

**Version:** `0.1.0`

**Kind:** Blueprint (agent-driven — run with `seihou agent run`, not `seihou run`)

## Overview

A [blueprint](https://github.com/shinzui/seihou) is an agent-driven runnable: instead of
producing deterministic output from a fixed set of variables, it captures authoring
intent in a prompt and lets a coding agent tailor the result to the target repository.

This blueprint generates a `release` skill specialized to *your* Haskell repo. When run,
the agent inspects the repository — build tooling (`cabal`/`stack`, Nix, treefmt,
pre-commit), every `*.cabal` file, single- vs multi-package layout, inter-package
dependency order, the publishable-vs-internal split, changelog and git-tag conventions,
check gates, and GitHub-release usage — then writes a `release` skill whose concrete
details match that repo. The bundled reference skill is used as a structural template,
not copied verbatim.

The publish/internal split is **always confirmed with the user** before the skill is
written, since publishing to Hackage is irreversible.

## Variables

| Name | Type | Default | Required | Validation | Description |
|------|------|---------|----------|------------|-------------|
| `skill.name` | `text` | `release` | yes | `[a-z][a-z0-9-]*` | Name of the generated skill directory under `agents/skills/`. Drives the agent prompt and the `seihou run link-skill --var skill.name=...` call that wires the skill into `.claude/skills` and `.agents/skills`. |

## Baseline

Before the agent launches, `seihou agent run` applies the blueprint's base modules as a
starting scaffold (file steps only — module commands are not run by the baseline):

- **`agent-gitignore`** — ensures `.claude/`, `.agents/`, and `CLAUDE.local.md` are in
  `.gitignore`.

Skip this phase with `--no-baseline`.

## Reference Files

Mounted read-only and listed in the agent's prompt as adaptable source material:

- `files/release-skill-reference.md` — a complete multi-package Hackage release skill
  (adapted from the shibuya project). Used as a structural template; every
  project-specific detail (package names, directories, dependency order, publishable
  set) is replaced with what the agent discovers in the target repo.

## What the agent produces

Running this blueprint results in:

- `agents/skills/<skill.name>/SKILL.md` — the tailored release skill (the committed
  source of truth).
- `.claude/skills/<skill.name>` and `.agents/skills/<skill.name>` — symlinks into the
  skill, created by the agent via `seihou run link-skill --var skill.name=<skill.name>`,
  so it is discoverable by Claude Code and other agent harnesses.

The generated skill itself covers: determining changes since the last tag, computing the
PVP bump, updating cabal versions / internal dependency bounds / changelogs, running the
project's format + build + test + check gates, committing/tagging/pushing, publishing to
Hackage in dependency order, and creating GitHub releases.

## Usage

Run in the Haskell repo you want a release skill for:

```bash
seihou agent run hackage-release
```

Override the generated skill's name, or skip the baseline:

```bash
seihou agent run hackage-release --var skill.name=publish
seihou agent run hackage-release --no-baseline
```

Print the resolved agent system prompt without launching the agent (no side effects):

```bash
seihou agent --debug run hackage-release --no-baseline
```

## See Also

- `blueprint.dhall` — full blueprint definition and authoritative source
- `prompt.md` — the agent task prompt
- `files/` — read-only reference material
- `agent-gitignore`, `link-skill` — the modules this blueprint relies on
