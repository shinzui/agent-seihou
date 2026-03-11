{ name = "exec-plan"
, description = Some "Claude skill for creating, implementing, and managing execution plans (ExecPlans) — self-contained design documents that guide implementation of features and system changes."
, vars =
  [ { name = "skill.name"
    , type = "text"
    , default = Some "exec-plan"
    , description = Some "Name of the skill directory"
    , required = True
    , validation = Some "[a-z][a-z0-9-]*"
    }
  ]
, exports =
  [ { var = "skill.name", alias = None Text }
  ]
, prompts = [] : List { var : Text, text : Text, when : Optional Text, choices : Optional (List Text) }
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
  ]
, commands = [] : List { run : Text, workDir : Optional Text, when : Optional Text }
, dependencies =
  [ { module = "claude-skill-link"
    , vars = [ { name = "skill.name", value = "exec-plan" } ]
    }
  ]
}
