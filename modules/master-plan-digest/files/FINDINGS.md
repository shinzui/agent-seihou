# MasterPlan Digest — Findings Catalog

Coordination-level rules that produce entries in `health.findings` and `human_attention`. Per-child ExecPlan findings live in `../exec-plan-digest/FINDINGS.md` and are surfaced inside `registry[i].digest.health.findings` when `--child-detail=full` is used; they are not duplicated at the MasterPlan level.

Add new rules here rather than inventing them in the skill prompt. Do not rename or repurpose existing codes.

## Severity

- `error` — the plan coordination is demonstrably broken or self-contradictory. Forces `health.score = red`.
- `warn` — a reviewer should act soon. Forces `yellow` unless an `error` is also present.
- `info` — worth noting, not acting on immediately.

## Priority (for `human_attention`)

- `high` — all `error` findings, plus any `warn` that likely blocks hand-off or forward progress of the whole initiative.
- `medium` — remaining `warn` findings.
- `low` — `info` findings.

Include `info` in `human_attention` only if fewer than five higher-priority items exist.

## Rules

Each rule specifies **When**, **Severity**, **Message**, **Evidence**, and **Suggested action**.

### REGISTRY_STATUS_MISMATCH

- **When**: any `registry[i].status_mismatch == true`.
- **Severity**: error if `declared_status == "Complete"` and `actual_status != "complete"`; warn otherwise.
- **Message**: "Registry declares <id> as \"<declared>\" but child plan shows \"<actual>\"."
- **Evidence**: `{ "id": "EP-X", "declared_status": "...", "actual_status": "...", "child_path": "..." }`
- **Suggested action**: "Update the registry Status cell to match the child plan, or update the child plan to reflect the registry state. Whichever is wrong, fix it once."

### CHILD_MISSING_BACKREF

- **When**: any path in `spec_compliance.children_missing_backref`.
- **Severity**: warn
- **Message**: "Child <id> has no `MasterPlan:` line in its header."
- **Evidence**: `{ "id": "EP-X", "child_path": "..." }`
- **Suggested action**: "Insert `MasterPlan: <masterplan-path>` immediately after the title heading of the child plan."

### REGISTRY_ORPHAN

- **When**: any `registry[i].file_exists == false`.
- **Severity**: error
- **Message**: "Registry lists <id> at `<path>` but the file does not exist."
- **Evidence**: `{ "id": "EP-X", "path": "..." }`
- **Suggested action**: "Create the child plan file, fix the path in the registry, or mark the entry Cancelled with a Decision Log note."

### FILESYSTEM_ORPHAN

- **When**: any path in `spec_compliance.filesystem_orphans`.
- **Severity**: warn
- **Message**: "Plan file at `<path>` declares `MasterPlan: <this>` but is not in the registry."
- **Evidence**: `{ "child_path": "...", "title": "..." }`
- **Suggested action**: "Add the plan to the Exec-Plan Registry (with a new EP-id, deps, and status) or remove the `MasterPlan:` line if it was attached by mistake."

### DEPENDENCY_CYCLE

- **When**: `dependency_graph.has_cycles == true`.
- **Severity**: error
- **Message**: "Hard dependencies contain a cycle."
- **Evidence**: `{ "cycle": ["EP-X", "EP-Y", "EP-X"] }` (if reconstructable, else `{}`)
- **Suggested action**: "Break the cycle by promoting one of the hard deps to a soft dep, or refactor the two plans so the cycle is unnecessary."

### CRITICAL_PATH_BLOCKED

- **When**: there exists an id in `dependency_graph.critical_path` that is in `dependency_graph.blocked`, AND there is no Decision Log entry dated within the last 14 days that explains the block.
- **Severity**: warn; error if the blocker has existed for ≥ 30 days (heuristic: earliest activity date on the blocked plan's file history, or the MasterPlan's `progress.days_since_last_activity`).
- **Message**: "Critical-path plan <id> is blocked on <deps> with no recent decision explaining the block."
- **Evidence**: `{ "id": "EP-X", "waiting_on": [...], "days_blocked": N }`
- **Suggested action**: "Add a Decision Log entry describing what is blocking progress and the plan to unblock it, or promote the blocking dependency to Complete / Cancelled."

### NO_READY_WORK

- **When**: `dependency_graph.ready_to_start == []` AND `dependency_graph.in_progress == []` AND not every plan is `complete` / `cancelled`.
- **Severity**: warn (error if the same condition has held for ≥ 21 days: inferred from commit history when available)
- **Message**: "No plan is ready to start or in progress, but the initiative is not finished."
- **Evidence**: `{ "remaining": N, "blocked_count": M }`
- **Suggested action**: "Investigate why every remaining plan is blocked. Typically one hard dep needs to be promoted to Complete or the decomposition needs revisiting."

### CASCADE_INCOMPLETE

- **When**: any `revisions[i]` has a non-empty `cascaded_to` AND at least one referenced child plan has no progress activity after `revisions[i].date`.
- **Severity**: warn
- **Message**: "Revision dated <date> says it cascaded into <ids>, but <child-id> shows no activity after that date."
- **Evidence**: `{ "revision_date": "...", "revision_summary": "...", "stale_children": ["EP-X"] }`
- **Suggested action**: "Verify the cascade actually landed in the named child plans. If it did, record a progress check-in; if not, complete the cascade now."

### INTEGRATION_POINT_VIOLATION

- **When**: a commit with `ExecPlan: <child-path>` trailer modifies a file listed in `integration_points[i].artifact` where the child is not in `consuming_plans` or the `owning_plan`. Requires `source.git_scan_enabled == true`.
- **Severity**: warn
- **Message**: "Commit <sha> under <id> modifies integration-point file `<file>` but <id> is not listed as owner or consumer of that artifact."
- **Evidence**: `{ "sha": "...", "id": "EP-X", "artifact": "...", "expected_plans": ["EP-Y", "EP-Z"] }`
- **Suggested action**: "Either add <id> to the integration point's consuming plans (with rationale in the Decision Log), or move the change into a plan that owns / consumes the artifact."

### TRAILER_ASYMMETRY_MISSING_MASTER

- **When**: `commits.coverage.execplan_only_under_this_master > 0`.
- **Severity**: warn
- **Message**: "<N> commits carry an `ExecPlan:` trailer for a child of this MasterPlan but are missing the `MasterPlan:` trailer."
- **Evidence**: `{ "count": N }`
- **Suggested action**: "Amend future commits to include both `MasterPlan:` and `ExecPlan:` trailers when working under this MasterPlan. Past commits can be left as-is unless rewriting history is worthwhile."

### TRAILER_ASYMMETRY_MISSING_EXECPLAN

- **When**: `commits.coverage.masterplan_only > 0` AND the commits are not purely MasterPlan-level edits (heuristic: the commit touches files under a subdirectory owned by a child plan per integration points).
- **Severity**: info
- **Message**: "<N> commits carry a `MasterPlan:` trailer but no `ExecPlan:` trailer, and touch child-plan files."
- **Evidence**: `{ "count": N }`
- **Suggested action**: "If the commits belong to a specific child, amend or future-commits should include an `ExecPlan:` trailer. Purely coordination commits (e.g., updating the registry) are fine without one."

### CANCELLED_WITH_DEPENDENTS

- **When**: a registry row has `actual_status == "abandoned"` or `declared_status == "Cancelled"` AND another registry row lists it in `hard_deps`.
- **Severity**: error
- **Message**: "<id> is Cancelled but <dependent-ids> still declare it as a hard dependency."
- **Evidence**: `{ "cancelled": "EP-X", "dependents": ["EP-Y", "EP-Z"] }`
- **Suggested action**: "Update each dependent's hard_deps to remove or redirect the dep, and record the rationale in the Decision Log."

### MASTER_STALE_VS_CHILDREN_ACTIVE

- **When**: `progress.days_since_last_activity` for the MasterPlan itself (derived from its Progress section and its own `MasterPlan:`-only commits) is ≥ 14 AND at least one child plan has activity within the last 7 days.
- **Severity**: warn
- **Message**: "MasterPlan has not been updated in <N> days but child plans are active."
- **Evidence**: `{ "master_last_activity": "...", "most_recent_child_activity": "...", "active_children": ["EP-X"] }`
- **Suggested action**: "Update the MasterPlan's Progress section to reflect recent child-plan work, and record any cross-plan discoveries or decisions that emerged."

### MISSING_SECTION

- **When**: `spec_compliance.missing_sections` is non-empty.
- **Severity**: error if the missing section is one of `Exec-Plan Registry`, `Progress`, `Decision Log`, `Outcomes & Retrospective`; warn otherwise.
- **Message**: "Required MasterPlan section(s) missing: <list>."
- **Evidence**: `{ "missing": [...] }`
- **Suggested action**: "Add the missing sections per MASTERPLAN.md. Coordination sections are mandatory."

### DECOMPOSITION_OUT_OF_RANGE

- **When**: the registry has fewer than 2 or more than 7 entries, AND no phases are defined.
- **Severity**: info
- **Message**: "MasterPlan has <N> child plans and no phases — outside the 2–7 guideline from MASTERPLAN.md."
- **Evidence**: `{ "child_count": N }`
- **Suggested action**: "With one plan, consider whether a MasterPlan is warranted at all (an ExecPlan may suffice). With more than seven, introduce phases to group related plans into implementation waves."

### REVISION_MISSING_CASCADE

- **When**: a `revisions[i].summary` mentions specific `EP-N` ids in its text but `revisions[i].cascaded_to == []`.
- **Severity**: info
- **Message**: "Revision dated <date> names child plans in its summary but did not populate `cascaded_to`."
- **Evidence**: `{ "revision_date": "...", "summary": "..." }`
- **Suggested action**: "Extraction heuristic only — if the revision did cascade into those plans, no action needed. Otherwise, record the cascade explicitly."

### GIT_SCAN_DISABLED

- **When**: `source.git_scan_enabled == false`.
- **Severity**: info
- **Message**: "Commit scan was disabled; trailer coverage and integration-point violations were not checked."
- **Evidence**: `{}`
- **Suggested action**: "Re-run without `--no-git` in a git checkout if those checks matter."

---

## Adding a new finding

1. Pick a stable `UPPER_SNAKE_CASE` code. Never rename or reuse.
2. Express the trigger in terms of schema fields. Extend the schema first if new data is required.
3. Choose severity conservatively. Reserve `error` for broken coordination.
4. Write the message as a template with placeholders.
5. Attach the minimum evidence a human needs to verify without re-reading the MasterPlan.
6. Always include a `suggested_action`.
