# ExecPlan Digest — Findings Catalog

This is the authoritative catalog of rules that produce entries in `health.findings` and `human_attention`. Each rule has a stable `code`, a severity, a trigger condition, and the evidence it must attach.

Add new rules here rather than inventing them in the skill prompt. Removing or renaming a code is a breaking schema change — avoid.

## Severity

- `error` — the plan is demonstrably broken or self-contradictory. One of these forces `health.score = red`.
- `warn` — something a reviewer should address soon. Forces `yellow` unless an `error` is also present.
- `info` — worth noting but not acting on immediately.

## Priority (for `human_attention`)

- `high` — all `error` findings, plus any `warn` that likely blocks hand-off to another contributor.
- `medium` — remaining `warn` findings.
- `low` — `info` findings.

Include `info` in `human_attention` only if there are fewer than five higher-priority items; do not drown the signal.

## Rules

Each rule below specifies:
- **When**: the condition, stated against extracted fields.
- **Severity**: error / warn / info.
- **Message**: template (substitute extracted values).
- **Evidence**: JSON fields to attach.
- **Suggested action**: what a human should do next.

### PROGRESS_COMPLETE_OUTCOMES_EMPTY

- **When**: `status.progress.done == status.progress.total && status.progress.total > 0 && outcomes.filled == false`
- **Severity**: error
- **Message**: "All progress items checked but Outcomes & Retrospective is empty."
- **Evidence**: `{ "done": N, "total": N }`
- **Suggested action**: "Fill Outcomes & Retrospective or re-open the final items that are actually pending."

### UNRESOLVED_DISCOVERY

- **When**: any `discoveries[i]` has `resolved == false` **and** `status.state == "complete"`.
- **Severity**: error
- **Message**: "Plan is marked complete but discovery is still unresolved: \"<summary>\"."
- **Evidence**: `{ "discovery_index": i, "summary": "..." }`
- **Suggested action**: "Link the discovery to a Decision Log entry or re-open the plan."

### ORPHANED_DISCOVERY

- **When**: `discoveries[i].resolved == null` AND no decision in the log references it AND the plan is not `not_started`.
- **Severity**: warn
- **Message**: "Discovery is recorded but never resolved or linked to a decision: \"<summary>\"."
- **Evidence**: `{ "discovery_index": i }`
- **Suggested action**: "Add a Decision Log entry explaining how the discovery shaped the approach, or mark it resolved."

### STALE_ACTIVE_PLAN

- **When**: `status.state == "active" && status.days_since_last_activity >= 14`
- **Severity**: warn (error if `>= 45`)
- **Message**: "Plan is active but has no activity in <N> days."
- **Evidence**: `{ "last_activity_date": "...", "days_since_last_activity": N, "open_items": M }`
- **Suggested action**: "Update Progress with current state, or explicitly mark the plan blocked / abandoned in the Decision Log."

### NEVER_STARTED

- **When**: `status.state == "not_started" && days since file creation (from `git log --diff-filter=A --follow --format=%cI -- <path> | tail -1`) >= 30`
- **Severity**: info
- **Message**: "Plan has existed for <N> days with no work logged."
- **Evidence**: `{ "created_date": "...", "days_since_creation": N }`
- **Suggested action**: "Start the plan, defer it with a Decision Log note, or delete it."

### WORK_WITHOUT_TRAILER

- **When**: `commits.suspected_unlinked.length > 0`
- **Severity**: warn
- **Message**: "<N> recent commits touch files named in this plan but are missing an ExecPlan trailer."
- **Evidence**: `{ "suspected_commits": [...] }`
- **Suggested action**: "Amend future commits to include `ExecPlan: <path>`, or add a Decision Log note explaining why these commits are out of scope."

### MISSING_SECTION

- **When**: `spec_compliance.missing_sections.length > 0`
- **Severity**: error (if missing Progress, Surprises, Decision Log, or Outcomes) / warn (for others)
- **Message**: "Required section(s) missing: <list>."
- **Evidence**: `{ "missing": ["Decision Log", ...] }`
- **Suggested action**: "Add the missing section per PLANS.md. Every ExecPlan must be self-contained and all required sections present."

### DECISION_NO_RATIONALE

- **When**: any decision has `has_rationale == false`
- **Severity**: warn
- **Message**: "Decision \"<summary>\" has no rationale."
- **Evidence**: `{ "decision_index": i }`
- **Suggested action**: "Document why the decision was made. PLANS.md requires rationale for every decision."

### DECISION_NO_DATE

- **When**: any decision has `has_date == false`
- **Severity**: info
- **Message**: "Decision \"<summary>\" has no date."
- **Evidence**: `{ "decision_index": i }`
- **Suggested action**: "Add `Date: YYYY-MM-DD` to the decision entry."

### INTENTION_TRAILER_GAP

- **When**: `spec_compliance.intention_in_header == true && spec_compliance.intention_trailer_coverage < 1.0 && commits.trailer_count > 0`
- **Severity**: warn
- **Message**: "Plan declares an Intention but only <pct>% of linked commits include the Intention trailer."
- **Evidence**: `{ "intention_id": "...", "coverage": 0.6, "trailer_count": 5 }`
- **Suggested action**: "Include `Intention: <id>` on all future commits for this plan."

### REVISION_WITHOUT_NOTE

- **When**: plan text shows multiple distinct dates in Progress spanning more than 30 days AND `spec_compliance.revision_note_present == false`
- **Severity**: info
- **Message**: "Plan appears to have been revised over time but has no revision notes."
- **Evidence**: `{ "earliest_progress_date": "...", "latest_progress_date": "..." }`
- **Suggested action**: "Append a revision note at the bottom of the plan describing what changed and why (PLANS.md § Revision Protocol)."

### SPLIT_ITEM_ORPHAN

- **When**: a progress item's text suggests it was split from another (phrases like "remaining:", "continues from", "part 2") but no matching earlier item is found.
- **Severity**: info
- **Message**: "Progress item appears to be a split continuation with no matching predecessor."
- **Evidence**: `{ "item_index": i, "text": "..." }`
- **Suggested action**: "Clarify the item text or restore the original 'done' entry for traceability."

### PURPOSE_MISSING_OBSERVABLE

- **When**: `purpose.observable_commands == []` AND `status.state in ["active", "complete"]`
- **Severity**: warn
- **Message**: "Purpose section names no observable command or output — acceptance is hard to verify."
- **Evidence**: `{}`
- **Suggested action**: "Add a concrete command + expected output to Purpose / Big Picture (PLANS.md § Content Guidelines)."

### MILESTONE_ACCEPTANCE_UNVERIFIED

- **When**: `milestones[i].state == "complete" && milestones[i].acceptance_met != true`
- **Severity**: warn
- **Message**: "Milestone \"<title>\" is marked complete but acceptance was not explicitly recorded."
- **Evidence**: `{ "milestone_index": i }`
- **Suggested action**: "Record the acceptance check in Progress (run the validation command, quote the output)."

### BLOCKED_WITHOUT_DECISION

- **When**: `status.state == "blocked"` AND no recent (last 14 days) Decision Log entry explains the block
- **Severity**: error
- **Message**: "Plan is blocked but no recent Decision Log entry explains what's blocking it or the next step."
- **Evidence**: `{}`
- **Suggested action**: "Add a Decision Log entry identifying the blocker and the plan to resolve it or abandon the ExecPlan."

---

## Adding a new finding

1. Pick a stable `UPPER_SNAKE_CASE` code. Do not reuse or rename existing codes.
2. Specify the trigger as a condition against schema fields. If it needs data that isn't in the schema, extend the schema first.
3. Choose severity conservatively. `error` means the plan is broken; reserve it.
4. Write the message template with placeholders for extracted values.
5. Attach the minimum evidence needed for a human to confirm the finding without re-reading the full plan.
6. Always include a `suggested_action`. A finding without an action is noise.
