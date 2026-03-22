let S =
      https://raw.githubusercontent.com/shinzui/seihou-schema/2b4035b/package.dhall
        sha256:21716b4aee783d8eb8b12c754050880fa710e881ecda85925f855ef34cc34a55

in  S.Module::{ name = "claude-skill-link"
, version = None Text
, description = Some "Symlink a Claude skill from claude/skills/ into .claude/skills/. Ensures .claude/skills/ exists and creates a relative symlink so the skill is discoverable by Claude Code."
, vars =
  [ { name = "skill.name"
    , type = "text"
    , default = None Text
    , description = Some "Name of the skill directory (e.g. rei-update-docs)"
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
, steps = [] : List { strategy : Text, src : Text, dest : Text, when : Optional Text, patch : Optional Text }
, commands =
  [ { run = "mkdir -p .claude/skills"
    , workDir = None Text
    , when = None Text
    }
  , { run = "ln -sfn ../../claude/skills/{{skill.name}} .claude/skills/{{skill.name}}"
    , workDir = None Text
    , when = None Text
    }
  ]
, dependencies = [ S.Dependency::{ module = "claude-gitignore" } ]
}
