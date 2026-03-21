

## Intention Tracking

When starting work in **create** or **implement** mode, use the `AskUserQuestion` tool to ask the user if they want to associate this work with an intention:

    Would you like to associate this work with an intention? If so, provide the Intention ID (or press enter to skip).

If the user provides an Intention ID, store it for the duration of the session and include an `Intention:` git trailer on every commit:

    Intention: <IntentionId>

When both an ExecPlan and an Intention are active, commits must include both trailers:

    Implement health-check endpoint

    Add GET /health route that returns 200 OK with uptime info.

    ExecPlan: docs/plans/add-health-check.md
    Intention: INTENT-42

Ask once at the start of a session. Do not ask again on subsequent commits within the same session. If the user skips or declines, proceed without the trailer.
