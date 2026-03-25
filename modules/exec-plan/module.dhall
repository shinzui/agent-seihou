let S =
      https://raw.githubusercontent.com/shinzui/seihou-schema/2b4035b/package.dhall
        sha256:21716b4aee783d8eb8b12c754050880fa710e881ecda85925f855ef34cc34a55

in  S.Module::{ name = "exec-plan"
, version = Some "0.1.2"
, description = Some "Claude skill for creating, implementing, and managing execution plans (ExecPlans) — self-contained design documents that guide implementation of features and system changes."
, vars =
  [ { name = "skill.name"
    , type = "text"
    , default = Some "exec-plan"
    , description = Some "Name of the skill directory"
    , required = True
    , validation = Some "[a-z][a-z0-9-]*"
    }
  , { name = "intentions.enabled"
    , type = "bool"
    , default = Some "false"
    , description = Some "Enable intention tracking — prompts the user for an Intention ID and adds an Intention: trailer to commits"
    , required = False
    , validation = None Text
    }
  ]
, exports =
  [ { var = "skill.name", alias = None Text }
  ]
, prompts =
  [ { var = "intentions.enabled"
    , text = "Enable intention tracking for commits?"
    , when = None Text
    , choices = None (List Text)
    }
  ]
, steps =
  [ { strategy = "copy"
    , src = "SKILL.md"
    , dest = "claude/skills/{{skill.name}}/SKILL.md"
    , when = None Text
    , patch = None Text
    }
  , { strategy = "copy"
    , src = "PLANS.md"
    , dest = "claude/skills/{{skill.name}}/PLANS.md"
    , when = None Text
    , patch = None Text
    }
  , { strategy = "copy"
    , src = "INTENTIONS-SECTION.md"
    , dest = "claude/skills/{{skill.name}}/SKILL.md"
    , when = Some "Eq intentions.enabled true"
    , patch = Some "append-section"
    }
  ]
, commands = [] : List { run : Text, workDir : Optional Text, when : Optional Text }
, dependencies =
  [ { module = "claude-skill-link"
    , vars = [ { name = "skill.name", value = "exec-plan" } ]
    }
  ]
}
