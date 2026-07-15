# ADR 1: Keep safety-critical blueprints self-contained across Seihou runtime versions

Status: Accepted

Date: 2026-07-15

## Context

Seihou blueprint runtime behavior changed between versions used by this registry. Seihou v0.3.0.0
listed blueprint reference filenames and descriptions but did not make their `files/` directory
readable by the launched agent. It also ignored a blueprint's `allowedTools` declaration. Seihou
v0.4.0.0 mounts the reference directory for interactive providers and merges declared tools into
the standard allow-list.

Two other v0.4 behaviors matter during authoring and validation. A successful debug render records
applied-blueprint provenance in `.seihou/manifest.json`, so it is not worktree-neutral. And
`Seihou.Core.Variable.simplePatternMatch` enforces only the literal
`[a-z][a-z0-9-]*` pattern; every other `ValPattern` currently passes. A blueprint declaration such
as `(ask|disposable|preserve)` therefore documents the intended interface but does not reject an
invalid CLI override on v0.4.

These differences are especially important for blueprints that may run database, deployment,
release, or other externally mutating commands. A missing reference or permissive variable must not
silently weaken a safety gate.

## Decision

Safety-critical blueprint prompts in this registry carry every rule required to choose and execute
their safe workflow inline. Reference files may provide deeper examples and provenance, but the
prompt must remain operable when those files are not mounted. Prompts explicitly read references
only when Seihou reports them reachable and never claim to have read inaccessible content.

Blueprints declare extra `allowedTools` only when pre-approval is an intentional part of their
contract. Workflows involving destructive or external commands may omit the field so those commands
continue to require interactive approval.

When a variable has a safety-relevant finite value set, the blueprint keeps the intended validation
declaration and also performs an immediate exact-value check in its prompt until the supported
Seihou runtime enforces that declaration. The invalid-value instruction must precede repository
inspection and tool calls.

Debug render tests run in a disposable temporary registry/project copy. Validation must not create
or update `.seihou/manifest.json` in the real target worktree.

## Consequences

Prompts duplicate a small amount of content from deeper reference files, so authors must review the
two surfaces for contradictions. In exchange, older and newer compatible Seihou versions preserve
the same safety behavior.

Prompt-level variable guards cannot make Seihou v0.4 return a nonzero process exit before rendering;
they make the launched agent stop before acting. Tests should accept either launcher rejection from
a validation-capable Seihou version or the immediate rendered stop guard from v0.4.

Interactive sessions may ask for more tool approvals. That is deliberate for destructive workflows,
where an operator should see the sanitized target and command before it runs.

## Evidence

The behavior and compatibility decision were discovered while implementing
[`docs/plans/1-add-an-adaptive-pg-migrate-keiro-stack-blueprint.md`](../plans/1-add-an-adaptive-pg-migrate-keiro-stack-blueprint.md).
The installed validation toolchain was Seihou `v0.4.0.0 (2aa69ce)`.
