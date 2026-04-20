---
name: master-plan-digest
description: >
  Produce a standardized JSON digest of a MasterPlan (or, explicitly, all of them).
  Parses the Exec-Plan Registry, computes the dependency graph (ready / blocked /
  critical path / parallel frontier), embeds per-child ExecPlan digests, cross-references
  git commit trailers (MasterPlan: and ExecPlan:), and surfaces coordination issues a
  human would miss when skimming — registry drift, missing back-references, cascade gaps,
  integration-point violations, blocked critical paths. Emits a single JSON envelope.
argument-hint: "<masterplan-path> | --all [--child-detail=full|summary|none] [--summary] [--no-git]"
allowed-tools: Bash, Read, Glob
user-invocable: true
---

# MasterPlan Digest

Produce a deterministic, machine-readable digest of one or all MasterPlans. The output is a single JSON envelope conforming to the schema below. Before emitting anything, read [FINDINGS.md](FINDINGS.md) — it is the authoritative catalog of coordination-level finding codes.

This skill composes with `exec-plan-digest`. For every child ExecPlan listed in a MasterPlan's registry, the output either embeds a full or summarised exec-plan digest, or omits the digest entirely (per `--child-detail`). When embedding, apply the exec-plan `FINDINGS.md` catalog at `../exec-plan-digest/FINDINGS.md` (relative to this skill's install directory) to the child digest before attaching it. Per-child findings appear inside `registry[i].digest.health.findings`, not at the MasterPlan level.

## Output Contract

Output **one** fenced code block tagged `json` and nothing else. No commentary before, between, or after. The fenced block must contain the envelope defined in "Schema" below. Every key must be present on every object; use `null` or `[]` for missing values. Never omit a key. Never add keys not in this schema.

If the request is impossible (e.g. `docs/masterplans/` does not exist), still emit the envelope with `masterplans: []` and a top-level `errors` array describing what went wrong.

## Arguments

The skill requires **either** a master-plan path **or** the `--all` flag. Processing every MasterPlan is never the default — running a full digest walks every child plan under every master and performs a commit scan for each, so selecting that scope must be deliberate.

- `<masterplan-path>` — Relative or absolute path to a single MasterPlan file. Required unless `--all` is given.
- `--all` — Process every `*.md` file in `docs/masterplans/`. Mutually exclusive with a path argument.
- `--child-detail=<full|summary|none>` — How much to include per child ExecPlan. Default `summary`.
  - `full` — emit the complete `exec-plan-digest` schema at `registry[i].digest`.
  - `summary` — include only `identity`, `status`, `health.score`, `human_attention` from the child digest. All other child fields are set to `null` or `[]`.
  - `none` — omit the child digest entirely (`registry[i].digest = null`). Downstream callers run `exec-plan-digest` themselves per child path.
- `--summary` — Trim MasterPlan-level body fields: drop `decomposition.alternatives_rejected`, full `decisions[].rationale` bodies, and `integration_points[].description`. Keep all counts, graph data, `health`, and `human_attention`. Independent of `--child-detail`.
- `--no-git` — Skip the git-log commit scan. By default, commit scanning is **on**: for each MasterPlan, run `git log --all --grep='MasterPlan: <path>' --format='%H %cI %s%n%b%n---'` from the repository root to populate `commits.*`. Integration-point violation detection is disabled when `--no-git` is used; an `INFO`-level finding records that limitation.

### Missing or ambiguous scope

If neither a path nor `--all` is supplied, do not guess and do not fall back to all plans. Emit the envelope with `masterplans: []` and one `errors` entry:

    {
      "code": "SCOPE_REQUIRED",
      "message": "master-plan-digest requires either a MasterPlan path or --all. Refusing to default to all master plans."
    }

If both are supplied, treat it the same way with `code: "SCOPE_CONFLICT"`.

## Procedure

1. **Resolve scope.** If `<masterplan-path>` is given and `--all` is not, use that path. If `--all` is given and no path is present, glob `docs/masterplans/*.md` from the repository root and sort ascending by the integer prefix in the filename (non-numeric prefixes sort last, alphabetically). Refuse on missing/conflicting scope.

2. **Read each MasterPlan file in full.** Ground every field in the actual text.

3. **Extract mechanical fields** (see "Extraction Rules") — identity, vision, decomposition, registry table, integration points, progress, discoveries, decisions, outcomes, revisions.

4. **Build the dependency graph** from registry `hard_deps` columns. Compute `ready_to_start`, `in_progress`, `blocked`, `complete`, `cancelled`, `parallel_frontier`, `critical_path`, and `has_cycles`.

5. **Compose child digests.** For each registry row whose `path` resolves to an existing file, build the per-child digest following the exec-plan-digest procedure, then trim according to `--child-detail`. Compute `actual_status` from the child's own progress and outcomes (same rule set as `exec-plan-digest`'s `status.state`), and set `status_mismatch = true` iff `declared_status` (normalized) disagrees with `actual_status`.

   Normalization: `Not Started → not_started`, `In Progress → active`, `Complete → complete`, `Cancelled → abandoned`. Any other declared label is treated as `null` and does not trigger `status_mismatch`.

6. **Run the commit scan** (unless `--no-git`) for the MasterPlan trailer. Additionally run `git log --grep='ExecPlan: docs/plans/<each-child>' --format='%H %B%n---' -- .` per child to cross-check trailer coverage: every commit should carry **both** `MasterPlan:` and `ExecPlan:` trailers when working under a child plan; count and classify.

7. **Detect integration-point violations** (only when git scan is enabled). For each `integration_points[i]`, for every commit under a consuming child plan (by `ExecPlan:` trailer), check whether the commit's `MasterPlan:` trailer matches this master. If an ExecPlan commit not in the consumer list of an artifact touches files named in `integration_points[i].artifact`, record it.

8. **Detect filesystem/registry orphans.**
   - `registry_orphans` = registry rows whose `path` doesn't exist on disk.
   - `filesystem_orphans` = files in `docs/plans/*.md` whose header contains `MasterPlan: <this MasterPlan path>` but whose path is not in the registry.

9. **Detect children missing back-reference.** For each registry row whose file exists, check the first 15 lines for a `MasterPlan:` line. If absent, append the path to `spec_compliance.children_missing_backref`.

10. **Apply every rule in FINDINGS.md** (this skill's catalog, not the exec-plan one) to produce `health.findings`. Derive `human_attention` as the prioritized subset with `suggested_action` attached.

11. **Compute `health.score`:** `red` if any finding has severity `error`, else `yellow` if any has severity `warn`, else `green`.

12. **Emit the envelope.** Validate shape before printing.

## Extraction Rules

### Identity

- `path` — repository-relative POSIX path.
- `number` — integer prefix in the filename, or `null`.
- `slug` — filename without number prefix and `.md` suffix.
- `title` — first `# ` heading text.
- `intention_id` — value of an `Intention:` line between the title and the living-document preamble, or `null`.

### Vision & Scope

Under `## Vision & Scope`:

- `summary` — first 1–2 sentences.
- `user_visible_behaviors` — items from any numbered list introduced by a phrase like "user-visible behaviors", "behaviors enabled", etc. If none, `[]`.
- `in_scope` / `out_of_scope` — bullets under explicit in-scope / out-of-scope headings or phrases. Recognize both "Out of scope for this MasterPlan:" and similar variants.

### Decomposition

Under `## Decomposition Strategy`:

- `summary` — first paragraph.
- `alternatives_rejected` — bullets or paragraphs under "Alternatives considered" / "Alternatives rejected" / similar.

### Registry

The `## Exec-Plan Registry` table. Expected columns: `#`, `Title`, `Path`, `Hard Deps`, `Soft Deps`, `Status`. Parse with tolerance for pipe/whitespace variations and markdown-link syntax in the `Path` cell.

- `id` — contents of `#` column, e.g. `EP-1`. If bare integers are used, render as `EP-<n>`.
- `number` — the integer extracted from `id`.
- `title` — contents of `Title` column.
- `path` — resolve any `[text](path)` markdown link in the `Path` column to the raw path. Convert `../plans/...` to `docs/plans/...` relative to repo root when obvious; otherwise keep the raw value and leave existence detection to step 5.
- `file_exists` — `true` if the file is readable.
- `hard_deps` / `soft_deps` — list of referenced `EP-N` ids (strip commas, "EP-" prefix kept). `None` / empty cell → `[]`.
- `declared_status` — verbatim string from the `Status` column.

### Phases

If the registry or a nearby section organizes plans into phases (headings like `### Phase 1`, `### Wave 2`, or prose mentioning "Phase N: ..."), extract them. Each phase has `name`, `child_plans` (list of `EP-N` ids), and `state` derived from member plans (`complete` when all children are Complete or Cancelled; `active` when any are In Progress; else `pending`). If no phases are used, `phases: []`.

### Dependency Graph

Adjacency is `{ <id>: [hard deps] }` — children always appear, with `[]` if no deps.

- `ready_to_start` — ids whose `declared_status` normalizes to `not_started` AND whose every hard dep normalizes to `complete` or `abandoned`.
- `in_progress` — ids with `declared_status` normalizing to `active`.
- `blocked` — ids with `declared_status` normalizing to `not_started` or `active`, at least one hard dep that is not yet `complete`/`abandoned`. Emit as `{ "id": "EP-X", "waiting_on": ["EP-Y", ...] }`.
- `complete` / `cancelled` — self-explanatory by normalized status.
- `parallel_frontier` — intersection of `ready_to_start ∪ in_progress` with cardinality ≥ 2 that share no direct hard-dep edges among themselves.
- `critical_path` — longest chain through the hard-dep DAG by plan count, starting from a node with no dependents-remaining-incomplete and ending at a leaf. On ties, choose the path containing the highest-numbered plans. Emit as an ordered list of ids.
- `has_cycles` — `true` if a cycle is detected. When `true`, leave `critical_path: []` and emit a `DEPENDENCY_CYCLE` finding.

### Integration Points

Under `## Integration Points`. Each numbered entry typically names a file and enumerates which plans touch it. Produce one object per point:

- `artifact` — the filename / path named by the entry. If multiple files are named, produce one entry per file with the same `owning_plan` / `consuming_plans`.
- `owning_plan` — the plan that first introduces the change (usually the earliest plan mentioned, or explicitly called out).
- `consuming_plans` — every other plan mentioned as touching the artifact.
- `description` — the prose following the file name, trimmed to roughly 200 chars. `null` under `--summary`.

### Progress

Under `## Progress`. Items are prefixed `EP-N:`. Parse each item like an exec-plan progress item (see exec-plan extraction rules), and additionally record which child plan it references via the `EP-N:` prefix.

- `progress.aggregate` — `done` / `total` / `percent` across the whole section.
- `progress.per_plan[<id>]` — `done` / `total` / `percent` for items scoped to each child id.
- `progress.current_focus` — text of the first unchecked item, prefixed with its plan id (`EP-1: ...`). `null` if all done.
- `progress.last_activity_date` — latest ISO date found in progress items **or** in commit scan output (whichever is newer). `null` if neither is available.
- `progress.days_since_last_activity` — integer days from `last_activity_date` to today (UTC), or `null`.

### Discoveries, Decisions, Outcomes

Same structure and rules as exec-plan-digest, applied to the MasterPlan's own sections.

### Revisions

Under `## Revisions` (or revision notes appended at the end of the file). One entry per dated note:

- `date` — ISO date (YYYY-MM-DD).
- `summary` — first ~200 chars.
- `cascaded_to` — list of `EP-N` ids if the note mentions cascading changes into specific child plans; `[]` otherwise. This drives the `CASCADE_INCOMPLETE` finding.

### Commits

When git scan is enabled:

    git log --all --grep="MasterPlan: <masterplan-path>" --format="%H|%cI|%s|%b|---" -- .

Parse each record's body for `MasterPlan:` and `ExecPlan:` trailer lines.

- `trailer_count` — total commits with the MasterPlan trailer.
- `last_commit_sha` — first 8 chars of newest match; `null` if none.
- `last_commit_date` — ISO date of newest match; `null` if none.
- `coverage.both_trailers` — count of commits with both `MasterPlan:` (this master) and any `ExecPlan:` trailer.
- `coverage.masterplan_only` — count with MasterPlan trailer but no ExecPlan trailer.
- `coverage.execplan_only_under_this_master` — commits with an `ExecPlan:` trailer matching a child in this registry but missing the `MasterPlan:` trailer. Requires a separate query per child:

        git log --all --grep="ExecPlan: <child-path>" --format="%H|%B|---"

  Count commits whose body lacks `MasterPlan: <this master>`.

- `suspected_unlinked` — commits since `last_activity_date - 7 days` that touch files named in this MasterPlan's integration points and carry neither trailer. Cap at 10.

### Spec Compliance

- `missing_sections` — required MasterPlan sections per MASTERPLAN.md: `Vision & Scope`, `Decomposition Strategy`, `Exec-Plan Registry`, `Dependency Graph`, `Integration Points`, `Progress`, `Surprises & Discoveries`, `Decision Log`, `Outcomes & Retrospective`.
- `revision_note_present` — `true` if a `## Revisions` section exists OR revision notes are appended at the bottom of the file.
- `children_missing_backref` — list of child paths whose header lacks a `MasterPlan:` line.
- `registry_orphans` — registry entries whose `path` doesn't exist on disk.
- `filesystem_orphans` — plan files with `MasterPlan: <this>` in their header that aren't in the registry.

## Schema

```json
{
  "schema_version": "1.0",
  "generated_at": "<ISO-8601 UTC>",
  "source": {
    "repo_root": "<absolute path>",
    "masterplans_dir": "docs/masterplans",
    "plans_dir": "docs/plans",
    "git_scan_enabled": true,
    "child_detail": "summary"
  },
  "errors": [],
  "masterplans": [
    {
      "identity": {
        "path": "docs/masterplans/1-qualified-agent-domain-extensions.md",
        "number": 1,
        "slug": "qualified-agent-domain-extensions",
        "title": "Qualified Agent Domain Extensions",
        "intention_id": "intention_01kpbspg9ve9hb61emxvr64ttf"
      },
      "vision": {
        "summary": "...",
        "user_visible_behaviors": [],
        "in_scope": [],
        "out_of_scope": []
      },
      "decomposition": {
        "summary": "...",
        "alternatives_rejected": []
      },
      "phases": [],
      "registry": [
        {
          "id": "EP-1",
          "number": 1,
          "title": "...",
          "path": "docs/plans/1-qa-optional-member-id.md",
          "file_exists": true,
          "hard_deps": [],
          "soft_deps": [],
          "declared_status": "Not Started",
          "actual_status": "not_started",
          "status_mismatch": false,
          "digest": null
        }
      ],
      "dependency_graph": {
        "adjacency": { "EP-1": [], "EP-2": ["EP-1"] },
        "ready_to_start": ["EP-1"],
        "in_progress": [],
        "blocked": [{ "id": "EP-2", "waiting_on": ["EP-1"] }],
        "complete": [],
        "cancelled": [],
        "parallel_frontier": [],
        "critical_path": ["EP-1", "EP-3", "EP-4"],
        "has_cycles": false
      },
      "integration_points": [
        {
          "artifact": "mls-service-v2-core/src/.../QualifiedAgentAggregate.hs",
          "owning_plan": "EP-1",
          "consuming_plans": ["EP-2", "EP-3", "EP-5"],
          "description": "QualifiedAgent record"
        }
      ],
      "progress": {
        "aggregate": { "done": 0, "total": 24, "percent": 0 },
        "per_plan": {
          "EP-1": { "done": 0, "total": 4, "percent": 0 }
        },
        "current_focus": "EP-1: Migration relaxes NOT NULL on member_id",
        "last_activity_date": "2026-04-16",
        "days_since_last_activity": 4
      },
      "discoveries": [],
      "decisions": [],
      "outcomes": { "filled": false, "summary": null, "gaps": [], "lessons": [] },
      "revisions": [
        { "date": "2026-04-16", "summary": "Added EP-5...", "cascaded_to": ["EP-2", "EP-3", "EP-4"] }
      ],
      "commits": {
        "trailer_count": 0,
        "last_commit_sha": null,
        "last_commit_date": null,
        "coverage": {
          "both_trailers": 0,
          "masterplan_only": 0,
          "execplan_only_under_this_master": 0
        },
        "suspected_unlinked": []
      },
      "spec_compliance": {
        "missing_sections": [],
        "revision_note_present": true,
        "children_missing_backref": [],
        "registry_orphans": [],
        "filesystem_orphans": []
      },
      "health": {
        "score": "yellow",
        "findings": [
          {
            "code": "CHILD_MISSING_BACKREF",
            "severity": "warn",
            "message": "Child EP-2 has no MasterPlan: line in its header",
            "evidence": { "child_path": "docs/plans/2-qa-admin-override-endpoints.md" },
            "suggested_action": "Add `MasterPlan: <path>` immediately after the title heading"
          }
        ]
      },
      "human_attention": [
        {
          "priority": "high",
          "code": "CHILD_MISSING_BACKREF",
          "what": "Child EP-2 has no MasterPlan: line",
          "where": "docs/plans/2-qa-admin-override-endpoints.md",
          "suggested_action": "Add `MasterPlan: <path>` immediately after the title heading"
        }
      ]
    }
  ]
}
```

## Child digest trimming

When `--child-detail=summary`, each `registry[i].digest` retains only these fields from the exec-plan-digest schema:

    {
      "identity": { ... },
      "status": { ... },
      "purpose": { "summary": "...", "user_visible_outcome": null, "observable_commands": [] },
      "milestones": [],
      "progress_items": [],
      "discoveries": [],
      "decisions": [],
      "outcomes": { "filled": <bool>, "summary": null, "gaps": [], "lessons": [] },
      "commits": { ... (kept) },
      "spec_compliance": { ... (kept) },
      "health": { "score": "...", "findings": [] },
      "human_attention": [ ... ]
    }

All other trimmed arrays are `[]`, not omitted. `health.findings` is emptied in summary mode — the `score` alone is kept; consumers who need the full findings list should run with `--child-detail=full` or call `exec-plan-digest` directly.

When `--child-detail=full`, `registry[i].digest` is the complete exec-plan-digest per-plan object.

When `--child-detail=none`, `registry[i].digest` is `null`. `actual_status` and `status_mismatch` are still computed from the child's raw Progress section.

## Determinism

- `masterplans` — by integer number ascending, then by slug.
- `registry` — by `number` ascending (document order, in practice).
- `dependency_graph.adjacency` — keys sorted alphabetically (`EP-1`, `EP-10`, `EP-2`, ... — sort by natural `(prefix, number)`, not lexical).
- `dependency_graph.ready_to_start`, `in_progress`, `complete`, `cancelled`, `parallel_frontier`, `critical_path` — same natural sort for the first four; `critical_path` preserves computed order.
- `integration_points` — document order.
- `revisions` — by `date` ascending.
- `health.findings` and `human_attention` — by `priority` (`high` → `medium` → `low`), then `code` alphabetically.

## Failure modes

- If a MasterPlan file is unreadable or malformed, include a best-effort entry with whatever fields parsed and append an entry to top-level `errors`.
- If the registry table fails to parse, still emit the MasterPlan with `registry: []`, `dependency_graph: { ... empty ... }`, and one error entry identifying the parse failure. All other sections are extracted normally.
- If a child plan file is missing, include the registry row with `file_exists: false`, `digest: null`, and a `REGISTRY_ORPHAN` finding.
- If git is unavailable, set `source.git_scan_enabled: false`, zero out all `commits.*`, emit one top-level error, and skip `INTEGRATION_POINT_VIOLATION` detection.
- Never abort the whole run because one MasterPlan failed.
