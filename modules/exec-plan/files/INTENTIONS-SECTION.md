

## Intention Tracking

Before asking any intention-related question, perform this mandatory preflight:

- In **create** mode, no target plan exists yet, so use the `AskUserQuestion` tool to ask the user if they want to associate this work with an intention.
- In **implement** mode, read the target ExecPlan's YAML frontmatter before doing anything else. If it contains a non-empty `intention` field, that value is authoritative: use it as the active Intention ID for the session. **Do not call `AskUserQuestion`, do not ask the user to confirm or replace it, and do not offer the Skip option.**
- If the ExecPlan has no non-empty `intention` field but has a `master_plan` field, read the referenced MasterPlan's YAML frontmatter. If the MasterPlan contains a non-empty `intention` field, inherit it, add it to the ExecPlan frontmatter, and **do not prompt**.
- Ask only when neither the ExecPlan nor its referenced MasterPlan provides a non-empty Intention ID.

When prompting, provide two options:

- **Yes** — "I have an Intention ID to associate with this work"
- **Skip** — "Proceed without linking an intention"

If the user selects "Yes", they will provide the Intention ID via the "Other" free-text input or as a follow-up.

If the user provides an Intention ID, store it for the duration of the session and:

1. **Pass it to the init script.** When creating a new ExecPlan, pass `--intention <IntentionId>` to `init-plan.ts`. The script writes it into the plan's YAML frontmatter (`intention: <IntentionId>`); do not add a body line for it. When implementing an existing plan whose frontmatter does not yet have an `intention` field, add it directly to the frontmatter block (do not introduce a body line).

2. **Include an `Intention:` git trailer on every commit:**

    ```text
    Intention: <IntentionId>
    ```

When both an ExecPlan and an Intention are active, commits must include both trailers:

```text
Implement health-check endpoint

Add GET /health route that returns 200 OK with uptime info.

ExecPlan: docs/plans/3-add-health-check.md
Intention: INTENT-42
```

Existing plan frontmatter takes precedence over the general instruction to ask at the start of create or implement work. Ask at most once per session and only after the mandatory preflight proves that no active plan provides an Intention ID. Do not ask again on subsequent commits within the same session. If the user skips or declines, proceed without the trailer.
