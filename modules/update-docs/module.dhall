let S =
      https://raw.githubusercontent.com/shinzui/seihou-schema/2b4035b/package.dhall
        sha256:21716b4aee783d8eb8b12c754050880fa710e881ecda85925f855ef34cc34a55

in  S.Module::{ name = "update-docs"
, version = None Text
, description = Some "Claude skill to update project documentation after code changes. Analyzes commits since last review and ensures docs stay in sync."
, vars =
  [ { name = "project.name"
    , type = "text"
    , default = None Text
    , description = Some "The name of the project (e.g. rei, myapp)"
    , required = True
    , validation = Some "[a-z][a-z0-9-]*"
    }
  , { name = "project.description"
    , type = "text"
    , default = None Text
    , description = Some "Short project description for context in the skill"
    , required = True
    , validation = None Text
    }
  , { name = "skill.name"
    , type = "text"
    , default = None Text
    , description = Some "Skill directory name, derived from project.name (e.g. rei-update-docs)"
    , required = True
    , validation = Some "[a-z][a-z0-9-]*"
    }
  , { name = "changelog.path"
    , type = "text"
    , default = Some "docs/user/CHANGELOG.md"
    , description = Some "Path to the changelog file that tracks the last reviewed commit"
    , required = True
    , validation = None Text
    }
  , { name = "docs.user.dir"
    , type = "text"
    , default = Some "docs/user"
    , description = Some "Directory for user-facing documentation"
    , required = True
    , validation = None Text
    }
  , { name = "docs.dev.dir"
    , type = "text"
    , default = Some "docs/dev"
    , description = Some "Directory for developer documentation"
    , required = True
    , validation = None Text
    }
  , { name = "source.dirs"
    , type = "text"
    , default = Some "src/"
    , description = Some "Comma-separated source directories to analyze for changes"
    , required = True
    , validation = None Text
    }
  , { name = "cli.commands.dir"
    , type = "text"
    , default = None Text
    , description = Some "Directory containing CLI command modules (e.g. src/Cli/Commands/)"
    , required = False
    , validation = None Text
    }
  , { name = "skills.dir"
    , type = "text"
    , default = Some "claude/skills"
    , description = Some "Directory containing Claude skill definitions"
    , required = False
    , validation = None Text
    }
  ]
, exports =
  [ { var = "skill.name", alias = None Text }
  ]
, prompts =
  [ { var = "project.name"
    , text = "What is your project name?"
    , when = None Text
    , choices = None (List Text)
    }
  , { var = "project.description"
    , text = "Short description of the project?"
    , when = None Text
    , choices = None (List Text)
    }
  , { var = "skill.name"
    , text = "Skill directory name (e.g. myproject-update-docs)?"
    , when = None Text
    , choices = None (List Text)
    }
  , { var = "changelog.path"
    , text = "Path to changelog file?"
    , when = None Text
    , choices = None (List Text)
    }
  , { var = "docs.user.dir"
    , text = "User documentation directory?"
    , when = None Text
    , choices = None (List Text)
    }
  , { var = "docs.dev.dir"
    , text = "Developer documentation directory?"
    , when = None Text
    , choices = None (List Text)
    }
  , { var = "source.dirs"
    , text = "Source directories to watch (comma-separated)?"
    , when = None Text
    , choices = None (List Text)
    }
  , { var = "cli.commands.dir"
    , text = "CLI commands directory (leave empty if no CLI)?"
    , when = None Text
    , choices = None (List Text)
    }
  , { var = "skills.dir"
    , text = "Claude skills directory?"
    , when = None Text
    , choices = None (List Text)
    }
  ]
, steps =
  [ { strategy = "template"
    , src = "SKILL.md.tpl"
    , dest = "claude/skills/{{skill.name}}/SKILL.md"
    , when = None Text
    , patch = None Text
    }
  ]
, commands = [] : List { run : Text, workDir : Optional Text, when : Optional Text }
, dependencies = [ { module = "claude-skill-link", vars = [] : List { name : Text, value : Text } } ]
}
