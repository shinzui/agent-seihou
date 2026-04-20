let S =
      https://raw.githubusercontent.com/shinzui/seihou-schema/2b4035b7e720a9b30642a8a27551592175732ee5/package.dhall
        sha256:21716b4aee783d8eb8b12c754050880fa710e881ecda85925f855ef34cc34a55

in  S.Module::{
    , name = "exec-plan-digest"
    , version = Some "0.1.0"
    , description = Some
        "Claude skill that produces a standardized JSON digest of ExecPlans — extracts status, progress, discoveries, decisions, and outcomes; cross-references git commit trailers; and surfaces issues a human skimming the plan would miss (stale active plans, orphaned discoveries, missing sections, contradictions)."
    , vars =
      [ S.VarDecl::{
        , name = "digest.skill.name"
        , type = "text"
        , default = Some "exec-plan-digest"
        , description = Some "Name of the exec-plan-digest skill directory"
        , required = True
        , validation = Some "[a-z][a-z0-9-]*"
        }
      , S.VarDecl::{
        , name = "exec-plan.skill.name"
        , type = "text"
        , default = Some "exec-plan"
        , description = Some
            "Name of the exec-plan skill this digest summarizes (kept in sync with the exec-plan dependency)"
        , required = True
        , validation = Some "[a-z][a-z0-9-]*"
        }
      ]
    , exports = [ { var = "digest.skill.name", alias = None Text } ]
    , prompts = [] : List S.Prompt.Type
    , steps =
      [ S.Step::{
        , strategy = "copy"
        , src = "SKILL.md"
        , dest = "claude/skills/{{digest.skill.name}}/SKILL.md"
        }
      , S.Step::{
        , strategy = "copy"
        , src = "FINDINGS.md"
        , dest = "claude/skills/{{digest.skill.name}}/FINDINGS.md"
        }
      ]
    , dependencies =
      [ S.Dependency::{
        , module = "exec-plan"
        , vars =
          [ { name = "skill.name", value = "exec-plan" } ]
        }
      , S.Dependency::{
        , module = "claude-skill-link"
        , vars =
          [ { name = "skill.name", value = "exec-plan-digest" } ]
        }
      ]
    }
