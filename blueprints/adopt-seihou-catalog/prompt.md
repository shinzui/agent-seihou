# Adopt or refresh the typed Seihou catalog

Run from the target Seihou registry checkout. Read its agent instructions and
inspect `git status --short`. Preserve existing work. Confirm the root has
`seihou-registry.dhall` and `mori.dhall`. Check that
`mori schema migrate --help` offers `--adopt-seihou-catalog`.

1. Run `seihou registry validate`. Read `mori.dhall` to find the generated
   documentation directory. Use `okf-docs` when no generated bundle is declared.
   For an existing catalog, resolve `documentationBundle` through `okfBundles`. Keep curated
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
   `mori schema migrate --adopt-seihou-catalog --dry-run`. Check that the candidate
   declares `seihouCatalog` and review the bundle binding. Apply it with
   `mori schema migrate --adopt-seihou-catalog --apply`. This applies ordinary
   manifest migrations and updates its schema pin as part of adoption.
   For an already declared catalog, use `mori schema migrate --apply` for
   ordinary manifest migrations. The adoption command looks for `okf-docs`.
   If the catalog is still unbound, use the name of the verified generated
   bundle in `okfBundles`. Add a declaration only when needed, keeping its
   actual path and profile.
4. Review legacy template overrides against the registry entries and artifact
   declarations. Fix stale versions or paths when the source confirms them.
   Preserve intentional metadata. If adoption carried a stale version into a
   typed override, let the typed feature inherit the registry version and align
   the legacy template with the authoritative declaration. Inspect the diff,
   then run `mori validate` and `git diff --check`.
5. Use `mori show --json` to get the project namespace and name. Refresh
   the project in its configured local PostgreSQL registry with
   `mori register --local`. Use the checkout's documented registry wrapper if
   it selects a different connection. Run
   `mori registry show NAMESPACE/NAME --full --json` against that same registry.
   Check `seihouCatalog.complete`, inspect its feature count and diagnostics,
   and verify the expected `documentationRef` links and `documentationState`
   values. Report missing, mismatched, or older-format documentation. If local
   registration is unavailable, report that after validating the files.

Report the manifest and bundle changes, the registered feature count, and any
unresolved diagnostics. Leave the file changes for review.
