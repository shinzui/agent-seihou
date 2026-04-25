let S =
      https://raw.githubusercontent.com/shinzui/seihou-schema/2b4035b7e720a9b30642a8a27551592175732ee5/package.dhall
        sha256:21716b4aee783d8eb8b12c754050880fa710e881ecda85925f855ef34cc34a55

in  S.Module::{
    , name = "link-skill"
    , version = Some "0.1.0"
    , description = Some
        "Symlink a skill from claude/skills/ into both .claude/skills/ and .agents/skills/. Ensures the target directories exist and creates relative symlinks so the skill is discoverable by Claude Code and other agent harnesses that read .agents/skills/."
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
            "ln -sfn ../../claude/skills/{{skill.name}} .claude/skills/{{skill.name}}"
        }
      , S.Command::{ run = "mkdir -p .agents/skills" }
      , S.Command::{
        , run =
            "ln -sfn ../../claude/skills/{{skill.name}} .agents/skills/{{skill.name}}"
        }
      ]
    , dependencies = [ S.Dependency::{ module = "claude-gitignore" } ]
    }
