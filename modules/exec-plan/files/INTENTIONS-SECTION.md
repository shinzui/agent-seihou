

## Intention Tracking

When starting work in **create** or **implement** mode, use the `AskUserQuestion` tool to ask the user if they want to associate this work with an intention. Provide two options:

- **Yes** — "I have an Intention ID to associate with this work"
- **Skip** — "Proceed without linking an intention"

If the user selects "Yes", they will provide the Intention ID via the "Other" free-text input or as a follow-up.

If the user provides an Intention ID, store it for the duration of the session and:

1. **Add it to the top of the plan.** When creating a new ExecPlan, include the Intention ID immediately after the title heading:

        # <Short, action-oriented title>

        Intention: <IntentionId>

        This ExecPlan is a living document. ...

    When implementing an existing plan that does not yet have an `Intention:` line, insert it in the same position (after the title, before the living-document preamble).

2. **Include an `Intention:` git trailer on every commit:**

        Intention: <IntentionId>

When both an ExecPlan and an Intention are active, commits must include both trailers:

    Implement health-check endpoint

    Add GET /health route that returns 200 OK with uptime info.

    ExecPlan: docs/plans/add-health-check.md
    Intention: INTENT-42

Ask once at the start of a session. Do not ask again on subsequent commits within the same session. If the user skips or declines, proceed without the trailer.
