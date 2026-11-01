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
  by: seihou-okf-extension/0.14.0.0
version: 0.1.0
---

# haskell-cli-app-with-agents

Extend the Haskell CLI repository recipe with agent ignore rules

**Version:** 0.1.0

## Extends

`haskell-cli-app-repo` from `https://github.com/shinzui/seihou-modules.git`; version >= `0.1.0` and < `0.2.0`. Selected from the source's default-branch HEAD; no historical tag search.

## Composes

- [agent-gitignore](/modules/agent-gitignore.md)

## Inherited module overrides

- `git-init` (with `git.githubOwner` = `shinzui`)

## Override rules

The oldest base supplies the primary module. Child literals override ancestor literals globally by variable name; defaults remain fallbacks. Explicit module overrides replace selected keys without adding instances. Prompt overrides replace inherited questions in place; new prompts append.
