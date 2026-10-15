let S =
      https://raw.githubusercontent.com/shinzui/seihou-schema/367b0a1390ac1ed3dda6e2cacfdf3e72b1f624df/package.dhall
        sha256:ef20d62c240dfe0e1126e05534d58c467188af4198307ad3c2a4a713bcd93505

in  S.Module::{
    , name = "link-skill"
    , version = Some "0.3.0"
    , description = Some
        "Symlink a skill from agents/skills/ into both .claude/skills/ and .agents/skills/. Records manifest-owned checkout links, restored by seihou sync in every clone (Seihou 0.10.0.0 or newer)."
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
      , S.Step::{
        , strategy = "symlink"
        , lifecycle = Some "checkout"
        , src = "agents/skills/{{skill.name}}"
        , dest = ".claude/skills/{{skill.name}}"
        }
      , S.Step::{
        , strategy = "symlink"
        , lifecycle = Some "checkout"
        , src = "agents/skills/{{skill.name}}"
        , dest = ".agents/skills/{{skill.name}}"
        }
      ]
    , dependencies = [ S.Dependency::{ module = "claude-gitignore" } ]
    }
