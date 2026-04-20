let S =
      https://raw.githubusercontent.com/shinzui/seihou-schema/2b4035b7e720a9b30642a8a27551592175732ee5/package.dhall
        sha256:21716b4aee783d8eb8b12c754050880fa710e881ecda85925f855ef34cc34a55

in  S.Module::{
    , name = "master-plan-digest"
    , version = Some "0.1.0"
    , description = Some
        "Claude skill that emits a standardized JSON digest of MasterPlans — parses the Exec-Plan Registry, computes the dependency graph (ready/blocked/critical path/parallel frontier), embeds per-child exec-plan-digest output, cross-references git commit trailers (MasterPlan: and ExecPlan:), and surfaces coordination issues a human would miss (registry drift, cascade gaps, integration-point violations, missing back-references)."
    , vars =
      [ S.VarDecl::{
        , name = "mp-digest.skill.name"
        , type = "text"
        , default = Some "master-plan-digest"
        , description = Some "Name of the master-plan-digest skill directory"
        , required = True
        , validation = Some "[a-z][a-z0-9-]*"
        }
      , S.VarDecl::{
        , name = "master-plan.skill.name"
        , type = "text"
        , default = Some "master-plan"
        , description = Some
            "Name of the master-plan skill this digest summarizes (kept in sync with the master-plan dependency)"
        , required = True
        , validation = Some "[a-z][a-z0-9-]*"
        }
      , S.VarDecl::{
        , name = "exec-plan-digest.skill.name"
        , type = "text"
        , default = Some "exec-plan-digest"
        , description = Some
            "Name of the exec-plan-digest skill used for per-child digests"
        , required = True
        , validation = Some "[a-z][a-z0-9-]*"
        }
      ]
    , exports = [ { var = "mp-digest.skill.name", alias = None Text } ]
    , prompts = [] : List S.Prompt.Type
    , steps =
      [ S.Step::{
        , strategy = "copy"
        , src = "SKILL.md"
        , dest = "claude/skills/{{mp-digest.skill.name}}/SKILL.md"
        }
      , S.Step::{
        , strategy = "copy"
        , src = "FINDINGS.md"
        , dest = "claude/skills/{{mp-digest.skill.name}}/FINDINGS.md"
        }
      ]
    , dependencies =
      [ S.Dependency::{
        , module = "master-plan"
        , vars =
          [ { name = "mp.skill.name", value = "master-plan" } ]
        }
      , S.Dependency::{
        , module = "exec-plan-digest"
        , vars =
          [ { name = "digest.skill.name", value = "exec-plan-digest" } ]
        }
      , S.Dependency::{
        , module = "claude-skill-link"
        , vars =
          [ { name = "skill.name", value = "master-plan-digest" } ]
        }
      ]
    }
