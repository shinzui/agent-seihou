# Docs-sync ledger reference

`docs/docs-sync.json` makes later audits incremental. It records discovery separately from audit
coverage so finding a surface never masquerades as reviewing it.

## Baseline invariants

- `sourceBaseline` is the source-project commit whose behavior was read against this surface.
- `targetBaseline` is the surface repository's own commit at that audit, and is used only when the
  surface lives in another repository.
- `coverage` is `never`, `partial`, or `full`.
- A null baseline means a full read is owed.
- A partial audit does not retire unaudited history. Keep the prior baseline unless the ledger has a
  richer range representation that preserves exactly what remains.
- Mechanical validation alone never advances a source baseline.
- Capture the source HEAD before docs edits and use that same audited SHA for every completed
  surface in the run.

## Portable reference shape

Preserve compatible project-specific fields in an existing ledger. For a new ledger, this shape is
a practical starting point:

```json
{
  "version": 1,
  "source": {
    "projectUri": "mori://namespace/project",
    "root": "."
  },
  "capabilities": {
    "cli": {
      "status": "confirmed",
      "checkedAtSource": "<full-source-sha>",
      "evidence": ["package manifest exposes the executable", "parser/router path"]
    },
    "embeddedCliHelp": {
      "status": "confirmed",
      "checkedAtSource": "<full-source-sha>",
      "evidence": ["asset glob", "embed callsite", "topic registry", "built help command"]
    },
    "embeddedAgentContext": {
      "status": "absent",
      "checkedAtSource": "<full-source-sha>",
      "evidence": ["no agent-facing command in the authoritative CLI inventory"]
    },
    "siblingKit": {
      "status": "ambiguous",
      "checkedAtSource": "<full-source-sha>",
      "evidence": ["candidate found by naming only; ownership not proven"]
    },
    "siblingDocs": {
      "status": "confirmed",
      "checkedAtSource": "<full-source-sha>",
      "repositoryUri": "mori://namespace/project-docs",
      "checkoutHint": "../project-docs",
      "evidence": ["source README identifies the public docs project"]
    }
  },
  "surfaces": {
    "readme": {
      "kind": "landing-page",
      "repositoryUri": "mori://namespace/project",
      "paths": ["README.md"],
      "transport": "plain-prose",
      "sourceBaseline": null,
      "sourceBaselineDate": null,
      "targetBaseline": null,
      "coverage": "never",
      "watch": ["src", "app", "package manifests", "build entrypoints"],
      "detectionEvidence": ["tracked root README used as repository landing page"],
      "notes": ""
    },
    "cli-help": {
      "kind": "cli-help",
      "repositoryUri": "mori://namespace/project",
      "paths": ["relative/help/assets", "relative/help/registry"],
      "transport": "embedded",
      "sourceBaseline": null,
      "sourceBaselineDate": null,
      "targetBaseline": null,
      "coverage": "never",
      "watch": ["CLI parser/router", "command implementations", "help assets", "build manifest"],
      "detectionEvidence": ["content -> embed -> registry -> built CLI reachability"],
      "notes": ""
    },
    "public-docs": {
      "kind": "public-docs",
      "repositoryUri": "mori://namespace/project-docs",
      "checkoutHint": "../project-docs",
      "paths": ["content/docs"],
      "transport": "plain-prose",
      "sourceBaseline": null,
      "sourceBaselineDate": null,
      "targetBaseline": null,
      "coverage": "never",
      "watch": ["public API", "CLI parser/router", "configuration/schema", "local user guides"],
      "detectionEvidence": ["canonical source-to-docs relationship"],
      "notes": ""
    }
  }
}
```

Replace descriptive placeholders in `watch` with real repository-relative paths. When uncertain,
prefer a broader tracked source path over a narrow watch list that can silently miss behavior.

`projectUri` and `repositoryUri` may be null only when canonical identity genuinely cannot be
derived. For cross-repository surfaces, use the intended canonical URI even if the current local
registry cannot resolve it; keep the project-relative path or checkout hint separate.

## Staleness

For a local surface with a valid baseline, count and inspect commits touching its `watch` paths in:

```text
sourceBaseline..audited-source-HEAD
```

For an external surface, evaluate both:

```text
source behavior: sourceBaseline..audited-source-HEAD
target edits:     targetBaseline..current-target-HEAD
```

Target edits do not automatically mean the surface is wrong, but they are part of the reconciliation
range. A missing source or target SHA is a history gap. Treat the affected surface as requiring a
full audit and retain the old value until that audit succeeds.

## Recording partial work

If only part of a surface was read, set `coverage` to `partial`, describe the exact files/claims
covered and still owed in `notes`, and do not move a single baseline past unaudited history. If the
project needs independently advancing clusters, split them into separate surface keys rather than
overloading one baseline.

## Capability changes

Adding a new capability creates a never-audited surface. Removing or moving one requires evidence of
the product change, reconciliation of its historical ledger entry, and documentation cleanup. Do not
erase the record to make the staleness table green.
