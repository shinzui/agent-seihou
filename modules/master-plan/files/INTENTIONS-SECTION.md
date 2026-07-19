


## Intention Tracking

Before asking any intention-related question, perform this mandatory preflight:

- In **create** mode, no target plan exists yet, so use the `AskUserQuestion` tool to ask the user if they want to associate this initiative with an intention.
- In **implement** mode, read the target MasterPlan's YAML frontmatter before doing anything else. If it contains a non-empty `intention` field, that value is authoritative: use it as the active Intention ID for the session. **Do not call `AskUserQuestion`, do not ask the user to confirm or replace it, and do not offer the Skip option.**
- Every child ExecPlan implemented under that MasterPlan inherits the active Intention ID. If a child lacks the `intention` field, add the inherited ID to its YAML frontmatter; **do not prompt again when selecting or switching child plans.**
- Ask only when the target MasterPlan has no non-empty Intention ID.

When prompting, provide two options:

- **Yes** — "I have an Intention ID to associate with this initiative"
- **Skip** — "Proceed without linking an intention"

If the user provides an Intention ID, store it for the duration of the session and:

1. **Pass it to the init scripts.** When creating a new MasterPlan, pass `--intention <IntentionId>` to `init-masterplan.ts`; when creating each child ExecPlan in the same session, pass the same `--intention <IntentionId>` to `init-plan.ts`. Both scripts write it into the plan's YAML frontmatter (`intention: <IntentionId>`); do not add a body line for it. When working with an existing plan whose frontmatter does not yet have an `intention` field, add it directly to the frontmatter block.

2. **Include an `Intention:` git trailer on every commit** alongside the other trailers:

    ```text
    Implement consumer group rebalance handling

    Add consumer group module with cooperative rebalance protocol.

    MasterPlan: docs/masterplans/1-kafka-consumer-pipeline.md
    ExecPlan: docs/plans/3-add-consumer-group.md
    Intention: INTENT-42
    ```

Existing plan frontmatter takes precedence over the general instruction to ask at the start of create or implement work. Ask at most once per session and only after the mandatory preflight proves that the active MasterPlan provides no Intention ID. Do not ask again on subsequent operations or child ExecPlans within the same session. If the user skips or declines, proceed without the trailer.
