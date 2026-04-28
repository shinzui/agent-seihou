let S =
      https://raw.githubusercontent.com/shinzui/seihou-schema/b83079d377f22c77292ad5ccf88d1061a58f0c1c/package.dhall
        sha256:1d46697ed3e7ca1b0d9922020e2da034ae6e33f7b482ee454c68d94b536e8c2a

in  S.Module::{
    , name = "exec-plan"
    , version = Some "0.3.0"
    , description = Some
        "Claude skill for creating, implementing, and managing execution plans (ExecPlans) — self-contained design documents that guide implementation of features and system changes."
    , vars =
      [ S.VarDecl::{
        , name = "skill.name"
        , type = "text"
        , default = Some "exec-plan"
        , description = Some "Name of the skill directory"
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
    , exports = [ { var = "skill.name", alias = None Text } ]
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
        , dest = "agents/skills/{{skill.name}}/SKILL.md"
        }
      , S.Step::{
        , strategy = "copy"
        , src = "PLANS.md"
        , dest = "agents/skills/{{skill.name}}/PLANS.md"
        }
      , S.Step::{
        , strategy = "copy"
        , src = "init-plan.ts"
        , dest = "agents/skills/{{skill.name}}/init-plan.ts"
        }
      , S.Step::{
        , strategy = "copy"
        , src = "INTENTIONS-SECTION.md"
        , dest = "agents/skills/{{skill.name}}/SKILL.md"
        , when = Some "Eq intentions.enabled true"
        , patch = Some "append-section"
        }
      ]
    , dependencies =
      [ S.Dependency::{
        , module = "link-skill"
        , vars = [ { name = "skill.name", value = "exec-plan" } ]
        }
      ]
    , migrations =
      [ S.Migration::{
        , from = "0.1.3"
        , to = "0.2.0"
        , ops =
          [ S.MigrationOp.MoveFile
              { src = "claude/skills/exec-plan/SKILL.md"
              , dest = "agents/skills/exec-plan/SKILL.md"
              }
          , S.MigrationOp.MoveFile
              { src = "claude/skills/exec-plan/PLANS.md"
              , dest = "agents/skills/exec-plan/PLANS.md"
              }
          , S.MigrationOp.RunCommand
              { run = "rm -rf .claude/skills/exec-plan claude/skills/exec-plan"
              , workDir = None Text
              }
          , S.MigrationOp.RunCommand
              { run = "mkdir -p .claude/skills .agents/skills"
              , workDir = None Text
              }
          , S.MigrationOp.RunCommand
              { run =
                  "ln -sfn ../../agents/skills/exec-plan .claude/skills/exec-plan"
              , workDir = None Text
              }
          , S.MigrationOp.RunCommand
              { run =
                  "ln -sfn ../../agents/skills/exec-plan .agents/skills/exec-plan"
              , workDir = None Text
              }
          ]
        }
      ]
    }
