let S =
      https://raw.githubusercontent.com/shinzui/seihou-schema/b83079d377f22c77292ad5ccf88d1061a58f0c1c/package.dhall
        sha256:1d46697ed3e7ca1b0d9922020e2da034ae6e33f7b482ee454c68d94b536e8c2a

in  S.Module::{
    , name = "master-plan"
    , version = Some "0.3.0"
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
        , dest = "agents/skills/{{mp.skill.name}}/SKILL.md"
        }
      , S.Step::{
        , strategy = "template"
        , src = "MASTERPLAN.md"
        , dest = "agents/skills/{{mp.skill.name}}/MASTERPLAN.md"
        }
      , S.Step::{
        , strategy = "copy"
        , src = "init-masterplan.ts"
        , dest = "agents/skills/{{mp.skill.name}}/init-masterplan.ts"
        }
      , S.Step::{
        , strategy = "copy"
        , src = "INTENTIONS-SECTION.md"
        , dest = "agents/skills/{{mp.skill.name}}/SKILL.md"
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
        , module = "link-skill"
        , vars = [ { name = "skill.name", value = "master-plan" } ]
        }
      ]
    , migrations =
      [ S.Migration::{
        , from = "0.1.0"
        , to = "0.2.0"
        , ops =
          [ S.MigrationOp.MoveFile
              { src = "claude/skills/master-plan/SKILL.md"
              , dest = "agents/skills/master-plan/SKILL.md"
              }
          , S.MigrationOp.MoveFile
              { src = "claude/skills/master-plan/MASTERPLAN.md"
              , dest = "agents/skills/master-plan/MASTERPLAN.md"
              }
          , S.MigrationOp.RunCommand
              { run =
                  "rm -rf .claude/skills/master-plan claude/skills/master-plan"
              , workDir = None Text
              }
          , S.MigrationOp.RunCommand
              { run = "mkdir -p .claude/skills .agents/skills"
              , workDir = None Text
              }
          , S.MigrationOp.RunCommand
              { run =
                  "ln -sfn ../../agents/skills/master-plan .claude/skills/master-plan"
              , workDir = None Text
              }
          , S.MigrationOp.RunCommand
              { run =
                  "ln -sfn ../../agents/skills/master-plan .agents/skills/master-plan"
              , workDir = None Text
              }
          ]
        }
      ]
    }
