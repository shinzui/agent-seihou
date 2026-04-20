---
name: exec-plan-digest
description: >
  Produce a standardized JSON digest of an ExecPlan (or, explicitly, all of them).
  Extracts status, progress, discoveries, decisions, and outcomes, cross-references
  git commit trailers, and surfaces issues a human skimming the plan would miss
  (stale active plans, orphaned discoveries, missing sections, contradictions).
  Emits a single JSON envelope suitable for dashboards, agent hand-offs, and
  automated reporting.
argument-hint: "<plan-path> | --all [--summary] [--no-git]"
allowed-tools: Bash, Read, Glob
user-invocable: true
---

# ExecPlan Digest

Produce a deterministic, machine-readable digest of one or all ExecPlans. The output is a single JSON envelope conforming to the schema below. Before emitting anything, read [FINDINGS.md](FINDINGS.md) — it is the authoritative catalog of finding codes and the rules that trigger them.

## Output Contract

Output **one** fenced code block tagged `json` and nothing else. No commentary before, between, or after. The fenced block must contain the envelope defined in "Schema" below. Every key must be present on every object; use `null` or `[]` for missing values. Never omit a key. Never add keys not in this schema.

If the request is impossible (e.g. `docs/plans/` does not exist), still emit the envelope with `plans: []` and a top-level `errors` array describing what went wrong. Do not write prose.

## Arguments

The skill requires **either** a plan path **or** the `--all` flag. Processing every plan is never the default — running a full digest reads dozens of files and performs a commit scan for each, so selecting that scope must be a deliberate choice, not the consequence of forgetting an argument.

- `<plan-path>` — Relative or absolute path to a single ExecPlan file. Required unless `--all` is given.
- `--all` — Process every `*.md` file in `docs/plans/`. Mutually exclusive with a path argument.
- `--summary` — Drop `progress_items`, full `decisions[].rationale` bodies, and `milestones[].body`. Keep all counts, `current_focus`, `health`, and `human_attention`.
- `--no-git` — Skip the git-log commit scan. By default, commit scanning is **on**: for each plan, run `git log --all --grep='ExecPlan: <plan-path>' --format='%H %cI'` from the repository root to populate `commits.trailer_count`, `commits.last_commit_sha`, and `commits.last_commit_date`. The default is on because detecting "work happened but no trailer" is one of the highest-value findings; `--no-git` exists only for environments without a git history.

### Missing or ambiguous scope

If neither a path nor `--all` is supplied, do not guess and do not fall back to all plans. Emit the envelope with `plans: []` and one `errors` entry:

    {
      "code": "SCOPE_REQUIRED",
      "message": "exec-plan-digest requires either a plan path or --all. Refusing to default to all plans."
    }

If both are supplied, treat it the same way with `code: "SCOPE_CONFLICT"` and refuse to run.

## Procedure

1. **Resolve scope.** If `<plan-path>` is given and `--all` is not, use that path verbatim. If `--all` is given and no path is present, glob `docs/plans/*.md` from the repository root and sort ascending by the integer prefix in the filename (plans without a numeric prefix sort last, alphabetically). If neither or both are supplied, stop and emit the scope error envelope described above.

2. **Read each plan file in full.** Do not summarize from memory; every field below must be grounded in the actual text.

3. **Extract mechanical fields first** (see "Extraction Rules"). These fields are deterministic and must be identical across runs on unchanged inputs.

4. **Run the commit scan** (unless `--no-git`) to populate `commits.*` and to refine `status.last_activity_date`.

5. **Apply every rule in FINDINGS.md.** Each matched rule produces one entry in `health.findings`. Then derive `human_attention` as the top-priority subset, ranked, with `suggested_action` attached.

6. **Compute `health.score`:** `red` if any finding has severity `error`, else `yellow` if any has severity `warn`, else `green`.

7. **Emit the envelope.** Validate it conforms before printing: every key present, arrays are arrays, dates are ISO-8601 strings or `null`.

## Extraction Rules

### Identity

- `path` — repository-relative path, POSIX style.
- `number` — the integer prefix in the filename, or `null` if none.
- `slug` — the filename without the number prefix and `.md` suffix.
- `title` — the text of the first `# ` heading.
- `intention_id` — the value of an `Intention: <id>` line near the top of the file (between the title and the living-document preamble), or `null`.

### Progress items

Checklist items live under the `## Progress` heading. Each line matching `- [ ]` or `- [x]` (case-insensitive) is one item. Continuation lines (indented under a checklist item) are part of the same item's `text`.

- `done` — `true` if `[x]`, else `false`.
- `date` — the last ISO-8601 date (`YYYY-MM-DD`) found in the item's text (often in trailing `(2026-04-20)`); `null` if absent.
- `split_from` — if the item text begins with a phrase like "remaining:" or clearly references an earlier item (e.g. "... continued from item N"), set this to that reference; else `null`. Do not guess.

`status.progress.done` / `total` / `percent` are computed from this list. `percent` is an integer 0–100 (round half-up).

### Current focus

`status.current_focus` is the full text (first 200 chars) of the first item where `done=false`. If all items are done, it is `null`.

### State

Derive `status.state` from the combination of progress, outcomes, and (if enabled) commits:

- `not_started` — zero progress items, or all items unchecked **and** no commits with trailer.
- `active` — some but not all items done, or `current_focus` is non-null.
- `complete` — all items done **and** `outcomes.filled` is true.
- `blocked` — any unresolved discovery with severity `error`, or the plan text contains an explicit "blocked" marker in Progress or Decision Log.
- `abandoned` — a decision log entry explicitly says the plan is abandoned/superseded; otherwise do not use this state.

### Milestones

Milestones may appear as `## Milestone N:` subheadings under `## Plan of Work`, or as inline paragraphs. Extract both, tagging each with `"source": "heading"` or `"source": "inferred"`. A milestone's `state` is `complete` if all progress items that reference it are done, `in_progress` if some are, else `pending`. `acceptance_met` is `true` only if the plan explicitly records acceptance for that milestone (e.g., a "verified" or "acceptance:" phrase in Progress); otherwise `null`, not `false`.

### Discoveries

Each entry under `## Surprises & Discoveries`. One bullet (or paragraph separated by blank lines) is one discovery.

- `has_evidence` — `true` if the entry contains a quoted command, log line, indented block, or inline code.
- `resolved` — `true` if the entry text contains "resolved", "fixed", or links to a Decision Log entry by date or phrasing; `false` if explicitly open; `null` if ambiguous.
- `linked_decision` — the `summary` of the matching decision, or `null`.

### Decisions

Each entry under `## Decision Log`. Parse `Decision:`, `Rationale:`, and `Date:` sub-fields when present.

- `has_rationale` — `true` if a `Rationale:` line exists and is non-empty.
- `has_date` — `true` if a `Date:` line exists and parses as a date.

### Outcomes

Under `## Outcomes & Retrospective`.

- `filled` — `false` if the section is empty, contains only the placeholder "(To be filled during and after implementation.)", or is whitespace. Else `true`.
- `summary` — first paragraph; `null` if `filled` is false.
- `gaps` — bullets under a "gaps", "remaining", or "not done" sub-phrase.
- `lessons` — bullets under a "lessons", "learned", or "retro" sub-phrase.

### Commits (when git scan is enabled)

Run, from the repository root:

    git log --all --grep="ExecPlan: <path>" --format="%H %cI %s" -- .

- `trailer_count` — number of matching commits.
- `last_commit_sha` — first 8 chars of the newest match, `null` if none.
- `last_commit_date` — ISO date (YYYY-MM-DD) of the newest match, `null` if none.
- `suspected_unlinked` — additional heuristic: run `git log --format='%H %cI %s' --since='<last_activity_date - 7 days>'` touching files that the plan explicitly names in its Plan of Work section, then filter out the linked ones. Cap at 10 entries. This surfaces work that likely belongs to the plan but is missing the trailer.

### Last activity date

`status.last_activity_date` = `max(latest progress item date, last_commit_date)`. `status.days_since_last_activity` = integer days from that date to today (UTC). If both sources are null, set `last_activity_date: null` and `days_since_last_activity: null`.

### Spec compliance

`spec_compliance.missing_sections` — any of the seven required section headings (`Purpose / Big Picture`, `Progress`, `Surprises & Discoveries`, `Decision Log`, `Outcomes & Retrospective`, `Context and Orientation`, `Plan of Work`, `Concrete Steps`, `Validation and Acceptance`) not found. Per PLANS.md all are mandatory.

- `revision_note_present` — `true` if the plan ends with one or more revision notes (typically under a `## Revision Notes` heading or marked "Revised:"); `null` if the plan has no revisions; `false` if sections were demonstrably changed but no note exists (hard to detect without history — default to `null` unless obvious).
- `intention_in_header` — `true` if an `Intention:` line exists in the header.
- `intention_trailer_coverage` — fraction of `commits.trailer_count` that also carry an `Intention:` trailer (1.0, 0.5, etc.); `null` if no intention or git disabled.

## Schema

```json
{
  "schema_version": "1.0",
  "generated_at": "<ISO-8601 UTC timestamp>",
  "source": {
    "repo_root": "<absolute path>",
    "plans_dir": "docs/plans",
    "git_scan_enabled": true
  },
  "errors": [],
  "plans": [
    {
      "identity": {
        "path": "docs/plans/22-fix-custom-property-entities-display-value.md",
        "number": 22,
        "slug": "fix-custom-property-entities-display-value",
        "title": "Fix `rei custom-property entities` showing `false` as the value",
        "intention_id": "intention_01kpnjgrn4e73v2ynqy9750gr5"
      },
      "status": {
        "state": "active",
        "progress": { "done": 12, "total": 13, "percent": 92 },
        "current_focus": "<first unchecked item text or null>",
        "last_activity_date": "2026-04-20",
        "days_since_last_activity": 0
      },
      "purpose": {
        "summary": "<1-2 sentence compression>",
        "user_visible_outcome": "<what the user can do after>",
        "observable_commands": []
      },
      "milestones": [
        {
          "title": "Milestone 1: ...",
          "source": "heading",
          "state": "complete",
          "acceptance_met": true,
          "body": "<narrative paragraph, or null in --summary mode>"
        }
      ],
      "progress_items": [
        { "text": "...", "done": true, "date": "2026-04-20", "split_from": null }
      ],
      "discoveries": [
        { "summary": "...", "has_evidence": true, "resolved": false, "linked_decision": null }
      ],
      "decisions": [
        { "summary": "...", "rationale": "...", "date": "2026-04-20", "has_rationale": true, "has_date": true }
      ],
      "outcomes": {
        "filled": false,
        "summary": null,
        "gaps": [],
        "lessons": []
      },
      "commits": {
        "trailer_count": 5,
        "last_commit_sha": "f4e4ae74",
        "last_commit_date": "2026-04-20",
        "suspected_unlinked": []
      },
      "spec_compliance": {
        "missing_sections": [],
        "revision_note_present": null,
        "intention_in_header": true,
        "intention_trailer_coverage": 1.0
      },
      "health": {
        "score": "yellow",
        "findings": [
          {
            "code": "STALE_ACTIVE_PLAN",
            "severity": "warn",
            "message": "Plan is 92% done but has no activity in 21 days",
            "evidence": { "last_activity_date": "2026-03-30", "open_items": 1 },
            "suggested_action": "Close out the remaining item or split it into a follow-up plan"
          }
        ]
      },
      "human_attention": [
        {
          "priority": "high",
          "code": "STALE_ACTIVE_PLAN",
          "what": "Plan is 92% done but has no activity in 21 days",
          "where": "Progress section",
          "suggested_action": "Close out the remaining item or split it into a follow-up plan"
        }
      ]
    }
  ]
}
```

## Determinism

Two runs on the same inputs must produce identical output except for `generated_at` and any commit-scan fields that reflect new git history. Sort arrays stably:

- `plans` — by integer number ascending, then by slug.
- `progress_items`, `discoveries`, `decisions` — in the order they appear in the source document.
- `milestones` — in document order.
- `health.findings` and `human_attention` — by `priority` (`high` → `medium` → `low`), then `code` alphabetically.

## Failure modes

- If a plan file is unreadable or malformed, include a best-effort entry with whatever fields parsed, and append an entry to top-level `errors` with `{ "path": "...", "message": "..." }`.
- If the git scan fails (not a git repo, git unavailable), set `source.git_scan_enabled: false`, leave all `commits.*` fields at their null/zero defaults, and add one top-level `errors` entry describing the failure. Continue processing.
- Never abort the whole run because one plan failed.
