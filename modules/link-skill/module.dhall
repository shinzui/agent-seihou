let S =
      https://raw.githubusercontent.com/shinzui/seihou-schema/b83079d377f22c77292ad5ccf88d1061a58f0c1c/package.dhall
        sha256:1d46697ed3e7ca1b0d9922020e2da034ae6e33f7b482ee454c68d94b536e8c2a

in  S.Module::{
    , name = "link-skill"
    , version = Some "0.2.0"
    , description = Some
        "Symlink a skill from agents/skills/ into both .claude/skills/ and .agents/skills/. Ensures the target directories exist and creates relative symlinks so the skill is discoverable by Claude Code and other agent harnesses that read .agents/skills/."
    , vars =
      [ S.VarDecl::{
        , name = "skill.name"
        , type = "text"
        , description = Some
            "Name of the skill directory (e.g. rei-update-docs)"
        , required = True
        , validation = Some "[a-z][a-z0-9-]*"
        }
      ]
    , prompts =
      [ S.Prompt::{
        , var = "skill.name"
        , text = "What is the skill directory name?"
        }
      ]
    , steps =
      [ S.Step::{
        , strategy = "template"
        , src = "gitignore.tpl"
        , dest = ".gitignore"
        , patch = Some "append-line-if-absent"
        }
      ]
    , commands =
      [ S.Command::{ run = "mkdir -p .claude/skills" }
      , S.Command::{
        , run =
            "ln -sfn ../../agents/skills/{{skill.name}} .claude/skills/{{skill.name}}"
        }
      , S.Command::{ run = "mkdir -p .agents/skills" }
      , S.Command::{
        , run =
            "ln -sfn ../../agents/skills/{{skill.name}} .agents/skills/{{skill.name}}"
        }
      ]
    , dependencies = [ S.Dependency::{ module = "claude-gitignore" } ]
    }
