


## Intention Tracking

When starting work in **create** or **implement** mode, use the `AskUserQuestion` tool to ask the user if they want to associate this work with an intention. Provide two options:

- **Yes** — "I have an Intention ID to associate with this initiative"
- **Skip** — "Proceed without linking an intention"

If the user provides an Intention ID, store it for the duration of the session and:

1. **Add it to the top of the MasterPlan.** When creating a new MasterPlan, include the Intention ID immediately after the title heading:

        # <Initiative Title>

        Intention: <IntentionId>

        This MasterPlan is a living document. ...

    When working with an existing MasterPlan that does not yet have an `Intention:` line, insert it in the same position (after the title, before the living-document preamble).

2. **Propagate it to every child ExecPlan** created during this session. Each child plan gets the same `Intention:` line after its title heading.

3. **Include an `Intention:` git trailer on every commit** alongside the other trailers:

        Implement consumer group rebalance handling

        Add consumer group module with cooperative rebalance protocol.

        MasterPlan: docs/masterplans/1-kafka-consumer-pipeline.md
        ExecPlan: docs/plans/3-add-consumer-group.md
        Intention: INTENT-42

Ask once at the start of a session. Do not ask again on subsequent operations within the same session. If the user skips or declines, proceed without the trailer.
