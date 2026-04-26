


## Intention Tracking

When starting work in **create** or **implement** mode, use the `AskUserQuestion` tool to ask the user if they want to associate this work with an intention. Provide two options:

- **Yes** — "I have an Intention ID to associate with this initiative"
- **Skip** — "Proceed without linking an intention"

If the user provides an Intention ID, store it for the duration of the session and:

1. **Pass it to the init scripts.** When creating a new MasterPlan, pass `--intention <IntentionId>` to `init-masterplan.ts`; when creating each child ExecPlan in the same session, pass the same `--intention <IntentionId>` to `init-plan.ts`. Both scripts write it into the plan's YAML frontmatter (`intention: <IntentionId>`); do not add a body line for it. When working with an existing plan whose frontmatter does not yet have an `intention` field, add it directly to the frontmatter block.

2. **Include an `Intention:` git trailer on every commit** alongside the other trailers:

        Implement consumer group rebalance handling

        Add consumer group module with cooperative rebalance protocol.

        MasterPlan: docs/masterplans/1-kafka-consumer-pipeline.md
        ExecPlan: docs/plans/3-add-consumer-group.md
        Intention: INTENT-42

Ask once at the start of a session. Do not ask again on subsequent operations within the same session. If the user skips or declines, proceed without the trailer.
