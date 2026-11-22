---
type: SeihouRecipe
title: haskell-cli-app-with-agents
description: Extend the Haskell CLI repository recipe with agent ignore rules
resource: seihou://agent-seihou/recipes/haskell-cli-app-with-agents
tags:
- haskell
- agents
- recipe
status: stable
generated:
  by: seihou-okf-extension/0.16.0.2
version: 0.1.0
---

# haskell-cli-app-with-agents

Extend the Haskell CLI repository recipe with agent ignore rules

**Version:** 0.1.0

## When to use

Use this recipe to apply its module composition together.

## How to use

Run from the project directory. Seihou resolves the base recipe and inherited bindings where declared. Supply remaining required inputs through project configuration, prompts or `--var KEY=VALUE`.

If the artifact is not installed, set `REGISTRY_GIT_URL` to the Git URL of its publishing registry and run:

```bash
seihou install "$REGISTRY_GIT_URL" --module haskell-cli-app-with-agents
```

```bash
seihou run haskell-cli-app-with-agents --dry-run
seihou run haskell-cli-app-with-agents
```

Review the composed plan before applying it. The recipe's bindings configure its modules, and the CLI overrides let you choose different values for this run.

## Declaration metadata

- description: `Bootstrap a Haskell CLI repository with shared agent ignore rules and a configured GitHub owner.`

## Extends

`haskell-cli-app-repo` from `https://github.com/shinzui/seihou-modules.git`; version >= `0.1.0` and < `0.2.0`. Selected from the source's default-branch HEAD; no historical tag search. This page documents the declared child; inherited declarations are not expanded.

## Composes

- [agent-gitignore](/modules/agent-gitignore.md) (declaring registry)

## Inherited module overrides

- `git-init` (with `git.githubOwner` = `shinzui`)

## Override rules

The oldest base supplies the primary module. Child literals override ancestor literals globally by variable name; defaults remain fallbacks. Explicit module overrides replace selected keys without adding instances. Prompt overrides replace inherited questions in place; new prompts append.
