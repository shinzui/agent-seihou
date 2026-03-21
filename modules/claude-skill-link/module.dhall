let S =
      https://raw.githubusercontent.com/shinzui/seihou-schema/6df1496a7ce06a693d8b63bd4cf2c5d4a136670c/package.dhall
        sha256:4946704e8c2dd295179003832428b82273fb0a0cff8eae9282b64ae7e18b89f4

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
, dependencies = [] : List { module : Text, vars : List { name : Text, value : Text } }
}
