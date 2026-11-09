---
type: SeihouModule
title: agent-gitignore
description: Ensure .claude/, .codex/, .agents/, and CLAUDE.local.md are in .gitignore
resource: seihou://agent-seihou/modules/agent-gitignore
tags:
- claude
- agents
- gitignore
- infrastructure
status: stable
generated:
  by: seihou-okf-extension/0.15.0.0
version: 0.2.0
---

# agent-gitignore

Ensure .claude/, .codex/, .agents/, and CLAUDE.local.md are in .gitignore

**Version:** 0.2.0

## Dependencies

This module has no dependencies.

## Variables

No variables declared.

## Exports

No exports declared.

## Generation steps

- `Template` `gitignore.tpl` → `.gitignore` (appends one line to a file another module owns, if absent)
