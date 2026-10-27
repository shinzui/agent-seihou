let S =
      https://raw.githubusercontent.com/shinzui/seihou-schema/7d02695f5a716384ec2174a018c20ee680ab3d13/package.dhall
        sha256:5a24b98eada6628e3e7da267f4e6c31c1e169179d2bacd5fed7254fc4cc55183

in  S.Module::{
    , name = "claude-skill-link"
    , version = Some "0.2.0"
    , description = Some
        "Symlink a Claude skill from claude/skills/ into .claude/skills/. Records a manifest-owned checkout link restored by seihou sync in every clone (Seihou 0.10.0.0 or newer)."
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
        , strategy = "symlink"
        , src = "claude/skills/{{skill.name}}"
        , dest = ".claude/skills/{{skill.name}}"
        , lifecycle = Some "checkout"
        }
      ]
    , dependencies = [ S.Dependency::{ module = "claude-gitignore" } ]
    }
