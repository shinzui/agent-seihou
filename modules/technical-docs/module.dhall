let S =
      https://raw.githubusercontent.com/shinzui/seihou-schema/367b0a1390ac1ed3dda6e2cacfdf3e72b1f624df/package.dhall
        sha256:ef20d62c240dfe0e1126e05534d58c467188af4198307ad3c2a4a713bcd93505

let skill =
      \(name : Text) ->
      \(source : Text) ->
        [ S.Step::{
          , strategy = "template"
          , src = "${source}/SKILL.md"
          , dest = "agents/skills/${name}/SKILL.md"
          }
        , S.Step::{
          , strategy = "copy"
          , src = "shared/WRITING-RULES.md"
          , dest = "agents/skills/${name}/WRITING-RULES.md"
          }
        , S.Step::{
          , strategy = "symlink"
          , lifecycle = Some "checkout"
          , src = "agents/skills/${name}"
          , dest = ".claude/skills/${name}"
          }
        , S.Step::{
          , strategy = "symlink"
          , lifecycle = Some "checkout"
          , src = "agents/skills/${name}"
          , dest = ".codex/skills/${name}"
          }
        , S.Step::{
          , strategy = "symlink"
          , lifecycle = Some "checkout"
          , src = "agents/skills/${name}"
          , dest = ".agents/skills/${name}"
          }
        ]

in  S.Module::{
    , name = "technical-docs"
    , version = Some "0.1.0"
    , description = Some
        "Agent skills for writing technical documentation: an entry skill that classifies the reader's need, and skills for tutorials, how-to guides, reference, explanations, and code walkthroughs."
    , vars =
      [ S.VarDecl::{
        , name = "skill.prefix"
        , type = "text"
        , default = Some "tech-docs"
        , description = Some
            "Name of the entry skill and prefix of the five form skills"
        , required = False
        , validation = Some "[a-z][a-z0-9-]*"
        }
      ]
    , exports = [ { var = "skill.prefix", alias = None Text } ]
    , steps =
          skill "{{skill.prefix}}" "router"
        # skill "{{skill.prefix}}-tutorial" "tutorial"
        # skill "{{skill.prefix}}-how-to" "how-to"
        # skill "{{skill.prefix}}-reference" "reference"
        # skill "{{skill.prefix}}-explanation" "explanation"
        # skill "{{skill.prefix}}-walkthrough" "walkthrough"
    , dependencies = [ S.Dependency::{ module = "agent-gitignore" } ]
    }
