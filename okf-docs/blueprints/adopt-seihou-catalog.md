---
type: SeihouBlueprint
title: adopt-seihou-catalog
description: Adopt or refresh Mori's typed Seihou catalog, regenerate OKF documentation,
  and verify feature links in the local registry
resource: seihou://agent-seihou/blueprints/adopt-seihou-catalog
tags:
- seihou
- mori
- okf
- registry
- migration
status: stable
generated:
  by: seihou-okf-extension/0.16.0.2
seihouMigrationEdges: []
version: 0.1.0
---

# adopt-seihou-catalog

Adopt or refresh Mori's typed Seihou catalog, regenerate OKF documentation, and verify feature links in the local registry

**Version:** 0.1.0

## When to use

Use this blueprint when you want an agent to carry out the task under Agent prompt.

## How to use

Run from the target project directory with an authenticated Seihou agent provider. Supply the declared variables and prompt answers. Review Base modules, Reference files and Tools before starting.

If the artifact is not installed, set `REGISTRY_GIT_URL` to the Git URL of its publishing registry and run:

```bash
seihou install "$REGISTRY_GIT_URL" --module adopt-seihou-catalog
```

```bash
seihou agent run adopt-seihou-catalog
```

Seihou applies the declared base modules, prepares the reference files and starts an agent session with the rendered task and tool permissions.

## Base modules

This blueprint declares no base modules.

## Agent prompt

```text
# Adopt or refresh the typed Seihou catalog

Run from the target Seihou registry checkout. Read its agent instructions and
inspect `git status --short`. Preserve existing work. Confirm the root has
`seihou-registry.dhall` and `mori.dhall`. Check that
`mori schema migrate --help` offers `--adopt-seihou-catalog`.

1. Run `seihou registry validate`. Find the generated documentation directory.
   Use `okf-docs` for first adoption. For an existing catalog, inspect its
   `documentationBundle` and resolve that name through `okfBundles`. Keep curated
   bundles and existing names. If the catalog binds a curated bundle, keep that
   binding and regenerate the separate generated bundle only where the project
   already has one.
2. Regenerate the Seihou bundle from the checkout. Use
   `seihou-okf-extension docs --dir . --out okf-docs` or
   `seihou extension run okf -- docs --dir . --out okf-docs`.
   Use the project's actual generated bundle path when it differs. Use
   `--force` only for a confirmed generator-owned directory. Compare against
   output in a temporary directory first if the destination contains changes
   or might include authored files. Preserve authored files and their bindings.
   Validate the generated bundle with
   `okf validate okf-docs --profile okf-docs/profile.dhall --strict --profile-enforce`
   using the matching paths.
3. For first adoption, run
   `mori schema migrate --adopt-seihou-catalog --dry-run`. Check the candidate
   declares `seihouCatalog` and binds the intended bundle. Apply it with
   `mori schema migrate --adopt-seihou-catalog --apply`. This applies ordinary
   manifest migrations and updates its schema pin as part of adoption.
   For an already declared catalog, use `mori schema migrate --apply` for
   ordinary manifest migrations. If an existing catalog is unbound, reuse a
   verified generated bundle declaration or add one without duplicating its
   name or path. Use `mori show --json` to check the resulting manifest.
4. Review legacy template overrides against the registry entries and artifact
   declarations. Fix stale versions or paths when the source confirms them.
   Preserve intentional metadata. If adoption carried a stale version into a
   typed override, let the typed feature inherit the registry version and align
   the legacy template with the authoritative declaration. Inspect the diff,
   then run `mori validate` and `git diff --check`.
5. Refresh the project in its configured local PostgreSQL registry with
   `mori register --local`. Use the checkout's documented registry wrapper if
   it selects a different connection. Run
   `mori registry show NAMESPACE/NAME --full --json` against that same registry.
   Check `seihouCatalog.complete`, inspect its feature count and diagnostics,
   and verify the expected `documentationRef` links and `documentationState`
   values. Report missing, mismatched, or older-format documentation. If local
   registration is unavailable, report that after validating the files.

Report the manifest and bundle changes, the registered feature count, and any
unresolved diagnostics. Leave the file changes for review.
```

## Reference files

No reference files declared.

## Tools

- `Bash(mori schema migrate *)`
- `Bash(mori show --json)`
- `Bash(mori validate)`
- `Bash(mori register --local)`
- `Bash(mori registry show *)`
- `Bash(okf validate *)`
- `Bash(seihou-okf-extension docs *)`
- `Bash(mktemp *)`
- `Bash(diff *)`
- `Bash(jq *)`


Blueprint runs also pre-approve Seihou setup tools.
