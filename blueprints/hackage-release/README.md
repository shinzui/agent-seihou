# hackage-release

> Generate a project-specific `release` skill that publishes Haskell packages to Hackage
> following PVP. An agent inspects the repo and writes a tailored skill — rather than a
> static one — then wires it into both `.claude/skills` and `.agents/skills`.

**Version:** `0.1.0`

**Kind:** Blueprint (agent-driven — run with `seihou agent run`, not `seihou run`)

## Overview

This blueprint generates a `release` skill specialized to *your* Haskell repository.
When run, the agent inspects the repo — cabal files, package layout, inter-package
dependency order, the publishable-vs-internal split, changelog and git-tag conventions,
nix/cabal check gates, and GitHub-release usage — then writes a skill whose concrete
details match that repo. It is for maintainers who want a repeatable, PVP-correct
Hackage release workflow without hand-maintaining a static skill.

## Variables

| Name | Type | Default | Required | Validation | Description |
|------|------|---------|----------|------------|-------------|
| `skill.name` | `text` | `release` | yes | `[a-z][a-z0-9-]*` | Name of the generated skill directory under `agents/skills/`. Used to template the agent prompt and to drive the `seihou run link-skill --var skill.name=...` invocation that wires the skill into `.claude/skills` and `.agents/skills`. |

## Baseline

Before the agent launches, `seihou agent run` applies these base modules as a starting
scaffold (file steps only — module commands are not run by the baseline):

- **`agent-gitignore`** — ensures `.claude/`, `.agents/`, and `CLAUDE.local.md` are in `.gitignore`.

Skip with `--no-baseline`.

## Reference Files

Mounted read-only and listed in the agent's prompt as adaptable source material:

- `files/release-skill-reference.md` — Reference example: a complete multi-package Hackage release skill (adapted from the shibuya project). Used as a structural template; every project-specific detail (package names, directories, dependency order, publishable set) is replaced with what the agent discovers in the target repo. Not copied verbatim.

## What the agent produces

The agent discovers how the target repo builds and releases, then **confirms the
publishable package set with the user** (mandatory — Hackage publishing is irreversible)
before writing `agents/skills/<skill.name>/SKILL.md`. The generated skill is tailored to
the repo and covers: determining changes since the last tag, computing the PVP bump,
updating cabal versions / internal dependency bounds / changelogs, running the project's
format + build + test + check gates, committing/tagging/pushing, publishing to Hackage in
dependency order, and creating GitHub releases. Finally the agent runs `link-skill` to
symlink the skill into both `.claude/skills` and `.agents/skills`, verifies the links
resolve, and offers to commit.

## Usage

Run in the target repository:

```bash
seihou agent run hackage-release
```

With variable overrides, or skipping the baseline:

```bash
seihou agent run hackage-release --var skill.name=publish
seihou agent run hackage-release --no-baseline
```

Print the resolved agent system prompt without launching the agent (no side effects):

```bash
seihou agent --debug run hackage-release --no-baseline
```

## Tags

`haskell`, `hackage`, `release`, `skill`, `claude`, `agents`

## See Also

- `blueprint.dhall` — full blueprint definition and authoritative source
- `prompt.md` — the agent task prompt
- `files/` — read-only reference material
