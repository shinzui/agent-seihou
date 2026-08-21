# Documentation capability discovery

This reference defines how to discover documentation and agent-context surfaces without assuming a
particular repository layout. Discovery is evidence gathering, not permission to edit every nearby
checkout.

## Surface record

For each capability, record:

- `status`: `confirmed`, `absent`, or `ambiguous`;
- `kind`: landing page, user guide, architecture, CLI help, agent context, kit, public docs, or a
  project-specific kind;
- repository identity and paths relative to that repository;
- transport when relevant: `embedded`, `runtime-loaded`, `generated`, or `plain-prose`;
- the evidence that establishes reachability and ownership;
- source watch paths that can invalidate its claims;
- mechanical invariants that can be checked without interpreting prose.

A path or filename is evidence, but is rarely enough to confirm a shipped surface by itself.

## Local prose

Start with tracked files and build/navigation manifests. Common candidates include the root README,
`docs/`, guide/reference directories, architecture/design records, changelogs, package-level READMEs,
and maintained agent instructions. Classify historical plans and generated output separately; their
existence does not make them current product documentation.

Confirm a prose surface when repository instructions, navigation/index files, packaging, or clear
maintainer convention show that readers or contributors are expected to use it. Do not treat every
Markdown file as one surface.

## CLI and help transport

First prove the project ships a CLI by reading its package/build manifest and command parser/router.
Obtain the command inventory from a binary built from the target worktree whenever possible.

For help guides, trace these edges:

```text
content assets -> embed/runtime loader -> topic registry or command dispatch -> shipped package -> CLI invocation
```

Record `embedded` only when content is compiled or bundled into the executable/package. Examples of
useful search anchors—not proof by themselves—include:

- Haskell: `embedFile`, `embedStringFile`, `Data.FileEmbed`, and Cabal source-file declarations;
- Rust: `include_str!` and `include_bytes!`;
- Go: `//go:embed` and `embed.FS`;
- Python: `importlib.resources`, package-data declarations, and wheel/sdist manifests;
- JavaScript/TypeScript: raw-text imports, bundler loaders, generated asset modules, and package-file
  allowlists.

Runtime filesystem loading is still a documentation surface, but record its transport honestly and
verify the package/install step includes the assets. A directory of help files with no reachable
registration or dispatch is a drift candidate, not proof of a shipped help surface.

Useful mechanical sets include content files on disk, loader/embed references, registered topics,
aliases, package/build inputs, and topic names shown by the built CLI. Compare the sets after
normalizing only syntax—not meaning.

## Agent-assist context

Do not assume an `agents/` or `prompts/` directory means the product embeds agent context. Start at
the real CLI/API command surface and locate agent-facing flows: names often include `agent`,
`assist`, `bootstrap`, `setup`, `copilot`, or `prompt`, but dispatch and tests are the evidence.

Trace each confirmed flow:

```text
standing context/prompt asset -> embed/runtime loader -> command handler -> provider/session launch
                              -> package/build inclusion
```

Distinguish standing product context from test fixtures, examples, user-authored prompt inputs, and
developer-only skills. Confirm reachability in source and, when safe, with a debug/dry-run command or
test that renders the resolved context without contacting a provider.

Mechanical checks compare prompt assets with embed/load declarations and command consumers. The
accuracy pass reads every standing instruction touched by the behavioral claim list, because stale
agent context causes the product to recommend incorrect actions even when ordinary docs are right.

## Local kit and skill catalogs

Confirm a local kit/skill surface through a catalog or install command, not merely a `skills/`
directory. Inspect manifest-to-disk membership, declared files, frontmatter mirrors, versions,
subagent registrations, and installation reachability. Follow repository-specific versioning rules.

## Sibling kit and public-docs repositories

Use this evidence order when external discovery is enabled:

1. Existing docs-sync ledger entries and explicit project configuration.
2. Workspace/submodule manifests and canonical cross-repository references in maintained docs.
3. The project's configured registry/corpus tool. When Mori is available and project instructions
   permit it, use the global/authoritative registry mode prescribed by the repository to inspect the
   current project and plausible documentation/skill projects.
4. A narrowly scoped listing of the project-group parent for conventional sibling names such as
   `<project>-docs`, `<project>-site`, `<project>-kit`, or `<project>-skills`.

Never accept naming alone. Confirm ownership with at least one stronger fact:

- the candidate identifies the source project's canonical URI or repository;
- it imports/generates content from the source repo;
- the source repo explicitly identifies it as the public docs or kit distribution;
- its catalog/site configuration is clearly for the source product;
- an existing trustworthy ledger records the relationship and the checkout still matches.

Prefer canonical project URIs for durable identity. Store a relative checkout hint separately for
local operation; do not commit machine-specific absolute paths. If a registry is unavailable, use
the intended canonical URI when its namespace/project identity is unambiguous and note that current
resolution could not be verified.

Multiple plausible candidates are `ambiguous`. Ask before editing. A missing checkout for a
confirmed relationship is a blocked external surface, not an absent relationship. With an explicit
local-only policy, record external discovery as skipped by policy and do not inspect sibling
contents.

## Re-probing and negative evidence

Capabilities change. Re-probe on every run even if the ledger previously recorded `absent`. Record
what was checked and the audited source HEAD/date so a future run can distinguish a real negative
result from an old assumption.

Do not delete a historical surface record just because current discovery fails. Determine whether
the surface was intentionally retired, moved, or is temporarily unavailable. Preserve the record
and explain the state until that question is settled.
