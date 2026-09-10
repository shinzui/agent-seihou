---
type: SeihouModule
title: claude-gitignore
description: Ensure .claude/ and CLAUDE.local.md are in .gitignore
resource: seihou://agent-seihou/modules/claude-gitignore
tags:
- claude
- gitignore
- infrastructure
status: stable
generated:
  by: seihou-okf-extension/0.8.0.0
version: 0.2.0
---

# claude-gitignore

Ensure .claude/ and CLAUDE.local.md are in .gitignore

**Version:** 0.2.0

## Dependencies

This module has no dependencies.

## Variables

No variables declared.

## Exports

No exports declared.

## Generation steps

- `Template` `gitignore.tpl` → `.gitignore` (appends one line to a file another module owns, if absent)
