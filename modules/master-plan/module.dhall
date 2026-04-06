let S =
      https://raw.githubusercontent.com/shinzui/seihou-schema/2b4035b7e720a9b30642a8a27551592175732ee5/package.dhall
        sha256:21716b4aee783d8eb8b12c754050880fa710e881ecda85925f855ef34cc34a55

in  S.Module::{
    , name = "master-plan"
    , version = Some "0.1.0"
    , description = Some
        "Claude skill for creating and managing master plans (MasterPlans) — coordination documents that decompose large initiatives into multiple ExecPlans with dependencies and integration points."
    , vars =
      [ S.VarDecl::{
        , name = "mp.skill.name"
        , type = "text"
        , default = Some "master-plan"
        , description = Some "Name of the master-plan skill directory"
        , required = True
        , validation = Some "[a-z][a-z0-9-]*"
        }
      , S.VarDecl::{
        , name = "exec-plan.skill.name"
        , type = "text"
        , default = Some "exec-plan"
        , description = Some
            "Name of the exec-plan skill directory (for cross-references in templates)"
        , required = True
        , validation = Some "[a-z][a-z0-9-]*"
        }
      , S.VarDecl::{
        , name = "intentions.enabled"
        , type = "bool"
        , default = Some "false"
        , description = Some
            "Enable intention tracking — prompts the user for an Intention ID and adds an Intention: trailer to commits"
        , required = False
        }
      ]
    , exports = [ { var = "mp.skill.name", alias = None Text } ]
    , prompts =
      [ S.Prompt::{
        , var = "intentions.enabled"
        , text = "Enable intention tracking for commits?"
        }
      ]
    , steps =
      [ S.Step::{
        , strategy = "template"
        , src = "SKILL.md"
        , dest = "claude/skills/{{mp.skill.name}}/SKILL.md"
        }
      , S.Step::{
        , strategy = "template"
        , src = "MASTERPLAN.md"
        , dest = "claude/skills/{{mp.skill.name}}/MASTERPLAN.md"
        }
      , S.Step::{
        , strategy = "copy"
        , src = "INTENTIONS-SECTION.md"
        , dest = "claude/skills/{{mp.skill.name}}/SKILL.md"
        , when = Some "Eq intentions.enabled true"
        , patch = Some "append-section"
        }
      ]
    , dependencies =
      [ S.Dependency::{
        , module = "exec-plan"
        , vars = [ { name = "skill.name", value = "exec-plan" } ]
        }
      , S.Dependency::{
        , module = "claude-skill-link"
        , vars = [ { name = "skill.name", value = "master-plan" } ]
        }
      ]
    }
