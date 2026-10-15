let S =
      https://raw.githubusercontent.com/shinzui/seihou-schema/367b0a1390ac1ed3dda6e2cacfdf3e72b1f624df/package.dhall
        sha256:ef20d62c240dfe0e1126e05534d58c467188af4198307ad3c2a4a713bcd93505

in  S.Module::{
    , name = "claude-skill-link"
    , version = Some "0.2.0"
    , description = Some
        "Symlink a Claude skill from claude/skills/ into .claude/skills/. Records a manifest-owned checkout link restored by seihou sync in every clone (Seihou 0.10.0.0 or newer)."
    , vars =
      [ { name = "skill.name"
        , type = "text"
        , default = None Text
        , description = Some
            "Name of the skill directory (e.g. rei-update-docs)"
        , required = True
        , validation = Some "[a-z][a-z0-9-]*"
        }
      ]
    , exports = [] : List { var : Text, alias : Optional Text }
    , prompts =
      [ { var = "skill.name"
        , text = "What is the skill directory name?"
        , when = None Text
        , choices = None (List Text)
        }
      ]
    , steps =
      [ S.Step::{
        , strategy = "symlink"
        , lifecycle = Some "checkout"
        , src = "claude/skills/{{skill.name}}"
        , dest = ".claude/skills/{{skill.name}}"
        }
      ]
    , dependencies = [ S.Dependency::{ module = "claude-gitignore" } ]
    }
